/*
================================================================================
CONSULTA DE CLASIFICACIÓN SALESFORCE
================================================================================
Propósito: Unir tablas de Salesforce (Opportunity, Account, User, Project__c)
           para obtener los campos especificados en clasificacion.csv

Nota: Esta es una consulta experimental para BigQuery, NO forma parte del flujo dbt
================================================================================
*/

--create or replace table deasol-prj-sandbox.status_03_gold_layer_salesforce.sf_prj_opps as (
WITH 

-- Base: Oportunidades con sus relaciones principales
oportunidades_base AS (
  SELECT
    -- IDs y relaciones
    opp.Id AS opportunity_id,
    opp.AccountId AS account_id,
    opp.OwnerId AS owner_id,
    opp.Name as opportunity_name,
    
    -- Campos de Opportunity según clasificacion.csv
    opp.Id AS id_oportunidad,
    opp.Volume__c AS volumen_opportunity,
    opp.CreatedDate AS fecha_creacion,
    opp.Business_Type__c AS tipo_negocio,
    opp.StageName AS etapa,
    opp.Work_Type__c AS tipo_obra,
    opp.SI2_Sub_etapas__c AS subetapa,
    opp.Job_Start_Date__c AS fecha_inicio,
    opp.Probability AS porcentaje_cierre,
    opp.PI2_Venta_por_piezas__c AS venta_por_piezas,
    opp.DS_Type_Market__c AS tipo_mercado,
    opp.Business_Type__c AS tipo_negocio_grupos,
    opp.Job_End_Date__c AS fecha_fin,
    opp.CloseDate AS fecha_cierre,
    opp.State__c AS estado,  -- Nota: clasificacion.csv menciona State_Name_c pero no existe en schema
    opp.CampaignId AS campania_id,
    
    -- Campos adicionales para cálculos
    opp.LastStageChangeDate AS ultima_fecha_cambio_etapa,
    opp.LastModifiedDate AS ultima_fecha_modificacion,
    opp.IsClosed AS esta_cerrada,
    opp.IsWon AS esta_ganada
    
  FROM 
    `dfor-prj-prod.salesforce_dstream.Opportunity` AS opp
  WHERE
    opp.IsDeleted = FALSE  -- Excluir registros eliminados
),

-- Cuentas (Account)
cuentas AS (
  SELECT
    acc.Id AS account_id,
    acc.SF_Name__c AS cuenta_nombre
  FROM 
    `dfor-prj-prod.salesforce_dstream.Account` AS acc
  WHERE
    acc.IsDeleted = FALSE
),

-- Usuarios (User) - Comerciales
usuarios AS (
  SELECT
    usr.Id AS user_id,
    usr.Name AS nombre_comercial
  FROM
    `dfor-prj-prod.salesforce_dstream.User` AS usr
  WHERE
    usr.IsActive = TRUE  -- Solo usuarios activos
),

-- Proyectos (Project__c)
proyectos AS (
  SELECT
    prj.Opportunity__c AS opportunity_id,
    -- Nota: Total_Weight_in_Ton_c no existe en schema, usando campos similares
    prj.Total_Delivered_Quantity_In_Ton__c,
    prj.Total_Pending_Quantity_in_Ton__c,
    prj.project_date__c AS fecha_captura,
    prj.Id AS project_id,
    prj.Name as project_name,
    prj.Commercial_System_ID__c
  FROM
    `dfor-prj-prod.salesforce_dstream.Project__c` AS prj
  WHERE
    prj.IsDeleted = FALSE
),

-- Historial de Oportunidades (OpportunityFieldHistory)
-- Para calcular FechaFinal y FechaFinal_EstatusAbierto
historial_oportunidades AS (
  SELECT
    hist.OpportunityId AS opportunity_id,
    -- Fecha máxima cuando cambió a estados cerrados/descartados
    MAX(CASE 
      WHEN hist.NewValue IN ('Closed Won', 'Closed Lost', 'Discarded') 
      THEN hist.CreatedDate 
    END) AS fecha_historial_cerrado,
    -- Fecha máxima cuando cambió a estados abiertos
    MAX(CASE 
      WHEN hist.NewValue IN ('New', 'Concurso', 'Cotización', 'Negotiation') 
      THEN hist.CreatedDate 
    END) AS fecha_historial_abierto
  FROM
    `dfor-prj-prod.salesforce_dstream.OpportunityFieldHistory` AS hist
  WHERE
    hist.IsDeleted = FALSE
    AND hist.NewValue IN ('Closed Won', 'Closed Lost', 'Discarded', 'New', 'Concurso', 'Cotización', 'Negotiation')
  GROUP BY
    hist.OpportunityId
),

-- Campañas (Campaign) - para LOOKUPVALUE del nombre de campaña
campanias AS (
  SELECT
    cmp.Id AS campaign_id,
    cmp.Name AS campania_nombre
  FROM
    `dfor-prj-prod.salesforce_dstream.Campaign` AS cmp
  WHERE
    cmp.IsDeleted = FALSE
)

-- Query final con todos los JOINs
SELECT
  -- Campos de Oportunidad
  opp.id_oportunidad,
  opp.opportunity_name,
  opp.volumen_opportunity AS volumen,
  opp.fecha_creacion,
  opp.tipo_negocio,
  opp.etapa,
  opp.tipo_obra,
  opp.subetapa,
  opp.fecha_inicio,
  opp.porcentaje_cierre,
  opp.venta_por_piezas,
  opp.tipo_mercado,
  opp.tipo_negocio_grupos,
  opp.fecha_fin,
  opp.fecha_cierre,
  opp.estado,
  opp.campania_id,
  
  -- Campos de Account
  cta.cuenta_nombre AS cuenta,
  
  -- Campos de User (Comercial)
  opp.owner_id AS comercial_id,
  usr.nombre_comercial,
  
  -- Campos de Project__c
  prj.project_id,
  prj.project_name,
  prj.Total_Delivered_Quantity_In_Ton__c,
  prj.Total_Pending_Quantity_in_Ton__c,
  prj.fecha_captura,
  Commercial_System_ID__c,
  
  -- Campo calculado: Lista de todos los proyectos de esta oportunidad
  -- Agrupa todos los nombres de proyectos asociados a la misma oportunidad, separados por , (coma)
  STRING_AGG(prj.project_name, ' ,  ') 
    OVER(
      PARTITION BY opp.opportunity_id 
      ORDER BY prj.project_name 
      ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) AS lista_proyectos_oportunidad,
  
  -- Campo calculado: Lista de fechas de captura de proyectos de esta oportunidad
  -- Agrupa todas las fechas de captura de proyectos asociados a la misma oportunidad, separadas por , (coma)
  STRING_AGG(CAST(prj.fecha_captura AS STRING), ' , ') 
    OVER(
      PARTITION BY opp.opportunity_id 
      ORDER BY prj.project_name 
      ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) AS lista_fechasCaptura_oportunidad_proyecto,
  
  -- Campo calculado: Tipo de Negocio Agrupado
  -- Agrupa los valores de Business_Type__c (de Opportunity) en categorías principales
  CASE
    WHEN opp.tipo_negocio_grupos IN (
      '2D&3D;SD',
      '2D&3D;AR;SD',
      '2D&3D;HV;SD',
      'SD',
      'SD;Instalación',
      'AR;SD',
      'AR;HV;SD',
      'HV;MI;SD'
    ) THEN 'AP'
    
    WHEN opp.tipo_negocio_grupos IN ('HP') THEN 'HP'
    
    WHEN opp.tipo_negocio_grupos IN (
      '2D&3D;HV',
      'AR;HV',
      'AR;HV;MI;HP',
      'AR;HV;PI;AP',
      'HV',
      'HV;AP',
      'HV;Instalación',
      'HV;MI',
      'HV;PI'
    ) THEN 'HV'
    
    WHEN opp.tipo_negocio_grupos IN ('MI') THEN 'MI'
    
    WHEN opp.tipo_negocio_grupos IN (
      '2D&3D',
      'AR',
      'AR;Instalación',
      'AR;MI'
    ) THEN 'Otros'
    
    ELSE 'No Clasificado'  -- Para valores no contemplados en la lista
  END AS tipo_de_negocio_agrupado,
  
  -- Campo calculado: Volumen Activo (Individual filtrado)
  -- Fórmula DAX original: CALCULATE(SUM(Oportunidad[Volume__c]), FILTER(Oportunidad, Etapa<>"Contratado"), FILTER(Oportunidad, Etapa<>"Perdido"))
  -- Muestra el volumen de esta oportunidad SOLO si NO está en "Closed Won" (Contratado) o "Closed Lost" (Perdido)
  CASE 
    WHEN opp.etapa NOT IN ('Closed Won', 'Closed Lost') 
    THEN opp.volumen_opportunity
    ELSE NULL
  END AS volumen_activo,
  
  -- Campo calculado: Fecha Final
  -- Fórmula DAX original: MAX(OpportunityFieldHistory[CreatedDate]) donde NewValue IN ('Closed Won', 'Closed Lost', 'Discarded')
  -- Si no hay historial, usa fecha de creación de la oportunidad
  COALESCE(
    hist.fecha_historial_cerrado,  -- Fecha máxima del historial cuando cambió a Closed Won/Lost/Discarded
    opp.fecha_creacion              -- Si no hay historial (ISBLANK), usa fecha de creación
  ) AS fecha_final,
  
  -- Campo calculado: Fecha Final Estatus Abierto
  -- Fórmula DAX original: MAX(OpportunityFieldHistory[CreatedDate]) donde NewValue IN ('New', 'Concurso', 'Cotización', 'Negotiation')
  -- Si no hay historial, usa fecha de creación de la oportunidad
  COALESCE(
    hist.fecha_historial_abierto,  -- Fecha máxima del historial cuando cambió a New/Concurso/Cotización/Negotiation
    opp.fecha_creacion              -- Si no hay historial (ISBLANK), usa fecha de creación
  ) AS fecha_final_estatus_abierto,
  
  -- Campo calculado: Etapa (traducida al español)
  -- Fórmula DAX original: SUBSTITUTE múltiple para traducir etapas
  CASE opp.etapa
    WHEN 'New' THEN 'Nuevo'
    WHEN 'Negotiation' THEN 'Cotización/Negociación'
    WHEN 'Closed Won' THEN 'Contratado'
    WHEN 'Closed Lost' THEN 'Perdido'
    WHEN 'Discarded' THEN 'Descartado'
    ELSE opp.etapa  -- Si no coincide con ninguno, mantener valor original
  END AS etapa_traducida,
  
  -- Campo calculado: Duración en Meses
  -- Fórmula DAX original: DATEDIFF(FechaInicio, FechaFin, MONTH) + 1
  -- Calcula la diferencia en meses entre fecha inicio y fecha fin
  CASE
    WHEN opp.fecha_inicio IS NOT NULL AND opp.fecha_fin IS NOT NULL
    THEN DATE_DIFF(opp.fecha_fin, opp.fecha_inicio, MONTH) + 1
    ELSE NULL
  END AS duracion_meses,
  
  -- Campo calculado: Oportunidad Vencida (indicador binario)
  -- Fórmula DAX original: CALCULATE(COUNTROWS(Oportunidad), Oportunidad[Job_Start_Date__c] < TODAY())
  -- Indica si la fecha de inicio ya pasó (oportunidad vencida): 1 = Vencida, 0 = No vencida
  CASE
    WHEN opp.fecha_inicio < CURRENT_DATE() THEN 1
    ELSE 0
  END AS es_oportunidad_vencida,
  
  -- Campo calculado: Oportunidad Por Vencer (indicador binario)
  -- Fórmula DAX original: CALCULATE(COUNTROWS(Oportunidad), Job_Start_Date__c >= TODAY(), Job_Start_Date__c <= TODAY() + 7)
  -- Indica si la fecha de inicio está en los próximos 7 días: 1 = Por vencer, 0 = No
  CASE
    WHEN opp.fecha_inicio >= CURRENT_DATE() 
     AND opp.fecha_inicio <= DATE_ADD(CURRENT_DATE(), INTERVAL 7 DAY)
    THEN 1
    ELSE 0
  END AS es_oportunidad_por_vencer,
  
  -- Campo calculado: Alerta Amarilla (próximos 7 días)
  -- Para usar en Looker Studio con formato condicional AMARILLO
  -- Indica si la fecha de inicio está dentro de los próximos 7 días (incluyendo hoy)
  CASE
    WHEN opp.fecha_inicio >= CURRENT_DATE() 
     AND opp.fecha_inicio <= DATE_ADD(CURRENT_DATE(), INTERVAL 7 DAY)
    THEN 'AMARILLO'
    ELSE NULL
  END AS alerta_amarilla,
  
  -- Campo calculado: Alerta Roja (fecha ya pasó)
  -- Para usar en Looker Studio con formato condicional ROJO
  -- Indica si la fecha de inicio ya pasó (es menor a hoy)
  CASE
    WHEN opp.fecha_inicio < CURRENT_DATE() THEN 'ROJO'
    ELSE NULL
  END AS alerta_roja,
  
  -- Campo calculado: Volumen Ganado (por registro)
  -- Muestra el volumen de esta oportunidad SOLO si está en 'Closed Won', sino 0
  CASE 
    WHEN opp.etapa = 'Closed Won' THEN opp.volumen_opportunity 
    ELSE 0 
  END AS volumen_ganado,
  
  -- Campo calculado: Volumen Perdido (por registro)
  -- Muestra el volumen de esta oportunidad SOLO si está en 'Closed Lost', sino 0
  CASE 
    WHEN opp.etapa = 'Closed Lost' THEN opp.volumen_opportunity 
    ELSE 0 
  END AS volumen_perdido,
  
  -- Campo calculado: Resultado de la Oportunidad (indicador)
  -- Para clasificar el registro: 'GANADO', 'PERDIDO', o NULL si no está cerrado en Won/Lost
  CASE 
    WHEN opp.etapa = 'Closed Won' THEN 'GANADO'
    WHEN opp.etapa = 'Closed Lost' THEN 'PERDIDO'
    ELSE NULL
  END AS resultado_oportunidad,
  
  -- Campo calculado: Campaña (LOOKUPVALUE del nombre de campaña)
  -- Fórmula DAX original: LOOKUPVALUE('Campaign'[Name], 'Campaign'[Id], Opportunity[CampaignId])
  cmp.campania_nombre AS campania

FROM 
  oportunidades_base AS opp

-- JOIN con Account (obligatorio, toda oportunidad debe tener una cuenta)
LEFT JOIN cuentas AS cta
  ON opp.account_id = cta.account_id

-- JOIN con User (obligatorio, toda oportunidad debe tener un owner/comercial)
LEFT JOIN usuarios AS usr
  ON opp.owner_id = usr.user_id

-- JOIN con Project__c (opcional, no todas las oportunidades tienen proyecto)
LEFT JOIN proyectos AS prj
  ON opp.opportunity_id = prj.opportunity_id

-- JOIN con OpportunityFieldHistory (opcional, para calcular FechaFinal)
LEFT JOIN historial_oportunidades AS hist
  ON opp.opportunity_id = hist.opportunity_id

-- JOIN con Campaign (opcional, para LOOKUPVALUE del nombre de campaña)
LEFT JOIN campanias AS cmp
  ON opp.campania_id = cmp.campaign_id

-- Ordenar por fecha de creación descendente
ORDER BY 
  opp.fecha_creacion DESC 
-- ) 