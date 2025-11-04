# ================================================================================

# SALESFORCE OPPORTUNITIES - LookML View
# ================================================================================
# Propósito: Vista analítica completa de oportunidades de Salesforce
# Fuente: mart_udn_das.salesforce_opportunities (tabla construida desde consulta_clasificacion_funcional.sql)
# Owner: Equipo de Analytics - Deacero Solutions
# ================================================================================

view: salesforce_opportunities {
  sql_table_name: `mart_udn_das.salesforce_opportunities` ;;

  # =======================================
  # PRIMARY KEY
  # =======================================

  dimension: id_oportunidad {
    primary_key: yes
    type: string
    label: "ID Oportunidad"
    description: "Identificador único de la oportunidad en Salesforce"
    sql: ${TABLE}.id_oportunidad ;;
    link: {
      label: "Ver en Salesforce"
      url: "https://deacero.lightning.force.com/lightning/r/Opportunity/{{ value }}/view"
      icon_url: "https://www.salesforce.com/favicon.ico"
    }
  }

  # =======================================
  # DIMENSIONES DE NEGOCIO - OPORTUNIDAD
  # =======================================

  dimension: opportunity_name {
    type: string
    label: "Nombre Oportunidad"
    description: "Nombre descriptivo de la oportunidad"
    sql: ${TABLE}.opportunity_name ;;
    link: {
      label: "Ver Oportunidad"
      url: "https://deacero.lightning.force.com/lightning/r/Opportunity/{{ id_oportunidad._value }}/view"
    }
  }

  dimension: etapa {
    type: string
    label: "Etapa (Original)"
    description: "Etapa actual de la oportunidad en inglés (StageName)"
    sql: ${TABLE}.etapa ;;
    order_by_field: etapa_orden
  }

  dimension: etapa_traducida {
    type: string
    label: "Etapa"
    description: "Etapa actual de la oportunidad traducida al español"
    sql: ${TABLE}.etapa_traducida ;;
    order_by_field: etapa_orden
  }

  # Hidden dimension para ordenar etapas correctamente
  dimension: etapa_orden {
    hidden: yes
    type: number
    sql: CASE ${etapa}
      WHEN 'New' THEN 1
      WHEN 'Concurso' THEN 2
      WHEN 'Cotización' THEN 3
      WHEN 'Negotiation' THEN 4
      WHEN 'Closed Won' THEN 5
      WHEN 'Closed Lost' THEN 6
      WHEN 'Discarded' THEN 7
      ELSE 99
    END ;;
  }

  dimension: subetapa {
    type: string
    label: "Sub-etapa"
    description: "Sub-etapa detallada de la oportunidad"
    sql: ${TABLE}.subetapa ;;
  }

  dimension: resultado_oportunidad {
    type: string
    label: "Resultado"
    description: "Resultado final de la oportunidad: GANADO, PERDIDO o en proceso"
    sql: ${TABLE}.resultado_oportunidad ;;
    html:
      {% if value == 'GANADO' %}
        <span style="color: #0F9D58; font-weight: bold;">✓ {{ value }}</span>
      {% elsif value == 'PERDIDO' %}
        <span style="color: #DB4437; font-weight: bold;">✗ {{ value }}</span>
      {% else %}
        <span style="color: #F4B400;">⏳ En Proceso</span>
      {% endif %} ;;
  }

  dimension: porcentaje_cierre {
    type: number
    label: "% Cierre"
    description: "Probabilidad de cierre (0-100)"
    sql: ${TABLE}.porcentaje_cierre ;;
    value_format_name: percent_0
  }

  # =======================================
  # CLASIFICACIÓN DE NEGOCIO
  # =======================================

  dimension: tipo_negocio {
    type: string
    label: "Tipo Negocio (Original)"
    description: "Tipo de negocio original de Salesforce (Business_Type__c)"
    sql: ${TABLE}.tipo_negocio ;;
  }

  dimension: tipo_de_negocio_agrupado {
    type: string
    label: "Tipo Negocio"
    description: "Tipo de negocio agrupado: AP, HP, HV, MI, Otros"
    sql: ${TABLE}.tipo_de_negocio_agrupado ;;
    order_by_field: tipo_negocio_orden
    drill_fields: [tipo_negocio]
  }

  # Hidden dimension para ordenar tipos de negocio
  dimension: tipo_negocio_orden {
    hidden: yes
    type: number
    sql: CASE ${tipo_de_negocio_agrupado}
      WHEN 'AP' THEN 1
      WHEN 'HP' THEN 2
      WHEN 'HV' THEN 3
      WHEN 'MI' THEN 4
      WHEN 'Otros' THEN 5
      ELSE 6
    END ;;
  }

  dimension: tipo_negocio_grupos {
    type: string
    label: "Tipo Negocio Grupos"
    sql: ${TABLE}.tipo_negocio_grupos ;;
    hidden: yes
  }

  dimension: tipo_obra {
    type: string
    label: "Tipo Obra"
    description: "Tipo de obra: Directa, Distribuidor, etc."
    sql: ${TABLE}.tipo_obra ;;
  }

  dimension: tipo_mercado {
    type: string
    label: "Tipo Mercado"
    description: "Segmento de mercado"
    sql: ${TABLE}.tipo_mercado ;;
  }

  # =======================================
  # DIMENSIONES DE VOLUMEN (para cálculos)
  # =======================================

  dimension: volumen {
    type: number
    label: "Volumen (Dim)"
    description: "Volumen total de la oportunidad en toneladas"
    sql: ${TABLE}.volumen ;;
    hidden: yes  # Se usa en measures
  }

  dimension: volumen_ganado {
    type: number
    label: "Volumen Ganado (Dim)"
    description: "Volumen si la oportunidad está en Closed Won"
    sql: ${TABLE}.volumen_ganado ;;
    hidden: yes
  }

  dimension: volumen_perdido {
    type: number
    label: "Volumen Perdido (Dim)"
    description: "Volumen si la oportunidad está en Closed Lost"
    sql: ${TABLE}.volumen_perdido ;;
    hidden: yes
  }

  dimension: volumen_activo {
    type: number
    label: "Volumen Activo (Dim)"
    description: "Volumen si la oportunidad NO está cerrada (ganada o perdida)"
    sql: ${TABLE}.volumen_activo ;;
    hidden: yes
  }

  # =======================================
  # DIMENSIONES TEMPORALES (dimension_group)
  # =======================================

  dimension_group: fecha_creacion {
    type: time
    label: "Fecha Creación"
    description: "Fecha de creación de la oportunidad"
    timeframes: [raw, time, date, week, month, month_name, quarter, quarter_of_year, year]
    datatype: datetime
    sql: ${TABLE}.fecha_creacion ;;
  }

  dimension_group: fecha_inicio {
    type: time
    label: "Fecha Inicio"
    description: "Fecha de inicio estimada del proyecto (Job_Start_Date__c)"
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}.fecha_inicio ;;
  }

  dimension_group: fecha_fin {
    type: time
    label: "Fecha Fin"
    description: "Fecha de fin estimada del proyecto (Job_End_Date__c)"
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}.fecha_fin ;;
  }

  dimension_group: fecha_cierre {
    type: time
    label: "Fecha Cierre"
    description: "Fecha de cierre esperada (CloseDate)"
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}.fecha_cierre ;;
  }

  dimension_group: fecha_captura {
    type: time
    label: "Fecha Captura Proyecto"
    description: "Fecha de captura del proyecto asociado"
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}.fecha_captura ;;
  }

  dimension_group: fecha_final {
    type: time
    label: "Fecha Final"
    description: "Fecha máxima cuando cambió a Closed Won, Closed Lost o Discarded"
    timeframes: [raw, time, date, week, month, quarter, year]
    datatype: datetime
    sql: ${TABLE}.fecha_final ;;
  }

  dimension_group: fecha_final_estatus_abierto {
    type: time
    label: "Fecha Final Estatus Abierto"
    description: "Fecha máxima cuando cambió a New, Concurso, Cotización o Negotiation"
    timeframes: [raw, time, date, week, month, quarter, year]
    datatype: datetime
    sql: ${TABLE}.fecha_final_estatus_abierto ;;
  }

  # =======================================
  # DIMENSIONES CALCULADAS - TIEMPO
  # =======================================

  dimension: duracion_meses {
    type: number
    label: "Duración (Meses)"
    description: "Duración del proyecto en meses (fecha_fin - fecha_inicio)"
    sql: ${TABLE}.duracion_meses ;;
  }

  dimension: es_oportunidad_vencida {
    type: yesno
    label: "¿Oportunidad Vencida?"
    description: "La fecha de inicio ya pasó (antes de hoy)"
    sql: ${TABLE}.es_oportunidad_vencida = 1 ;;
  }

  dimension: es_oportunidad_por_vencer {
    type: yesno
    label: "¿Oportunidad Por Vencer?"
    description: "La fecha de inicio está en los próximos 7 días"
    sql: ${TABLE}.es_oportunidad_por_vencer = 1 ;;
  }

  # =======================================
  # ALERTAS Y FORMATOS CONDICIONALES
  # =======================================

  dimension: alerta_amarilla {
    type: string
    label: "Alerta Amarilla"
    description: "Alerta para fechas de inicio en los próximos 7 días"
    sql: ${TABLE}.alerta_amarilla ;;
    html:
      {% if value == 'AMARILLO' %}
        <div style="background-color: #FFF9C4; color: #F57F17; padding: 4px 8px; border-radius: 4px; font-weight: bold; text-align: center;">
          ⚠️ PRÓXIMO
        </div>
      {% endif %} ;;
  }

  dimension: alerta_roja {
    type: string
    label: "Alerta Roja"
    description: "Alerta para fechas de inicio que ya pasaron"
    sql: ${TABLE}.alerta_roja ;;
    html:
      {% if value == 'ROJO' %}
        <div style="background-color: #FFCDD2; color: #C62828; padding: 4px 8px; border-radius: 4px; font-weight: bold; text-align: center;">
          🔴 VENCIDO
        </div>
      {% endif %} ;;
  }

  dimension: estado_alerta_consolidado {
    type: string
    label: "Estado Alerta"
    description: "Estado consolidado de alertas (Rojo > Amarillo > OK)"
    sql: CASE
      WHEN ${alerta_roja} = 'ROJO' THEN 'VENCIDO'
      WHEN ${alerta_amarilla} = 'AMARILLO' THEN 'PRÓXIMO'
      ELSE 'OK'
    END ;;
    html:
      {% if value == 'VENCIDO' %}
        <div style="background-color: #FFCDD2; color: #C62828; padding: 4px 8px; border-radius: 4px; font-weight: bold; text-align: center;">
          🔴 {{ value }}
        </div>
      {% elsif value == 'PRÓXIMO' %}
        <div style="background-color: #FFF9C4; color: #F57F17; padding: 4px 8px; border-radius: 4px; font-weight: bold; text-align: center;">
          ⚠️ {{ value }}
        </div>
      {% else %}
        <div style="background-color: #C8E6C9; color: #2E7D32; padding: 4px 8px; border-radius: 4px; font-weight: bold; text-align: center;">
          ✓ {{ value }}
        </div>
      {% endif %} ;;
  }

  # =======================================
  # RELACIONES - CUENTA, COMERCIAL, PROYECTO
  # =======================================

  dimension: cuenta {
    type: string
    label: "Cuenta"
    description: "Nombre de la cuenta de Salesforce"
    sql: ${TABLE}.cuenta ;;
  }

  dimension: comercial_id {
    type: string
    label: "ID Comercial"
    sql: ${TABLE}.comercial_id ;;
    hidden: yes
  }

  dimension: nombre_comercial {
    type: string
    label: "Comercial"
    description: "Nombre del usuario owner de la oportunidad"
    sql: ${TABLE}.nombre_comercial ;;
  }

  dimension: project_id {
    type: string
    label: "ID Proyecto"
    sql: ${TABLE}.project_id ;;
    hidden: yes
  }

  dimension: project_name {
    type: string
    label: "Nombre Proyecto"
    description: "Nombre del proyecto asociado (Project__c)"
    sql: ${TABLE}.project_name ;;
  }

  dimension: commercial_system_id__c {
    type: string
    label: "ID Sistema Comercial"
    description: "ID del proyecto en el sistema comercial (Kraken/Masterview)"
    sql: ${TABLE}.Commercial_System_ID__c ;;
  }

  dimension: lista_proyectos_oportunidad {
    type: string
    label: "Lista Proyectos"
    description: "Todos los proyectos asociados a esta oportunidad (separados por coma)"
    sql: ${TABLE}.lista_proyectos_oportunidad ;;
  }

  dimension: lista_fechas_captura_oportunidad_proyecto {
    type: string
    label: "Lista Fechas Captura Proyectos"
    description: "Fechas de captura de todos los proyectos asociados"
    sql: ${TABLE}.lista_fechasCaptura_oportunidad_proyecto ;;
  }

  dimension: campania_id {
    type: string
    label: "ID Campaña"
    sql: ${TABLE}.campania_id ;;
    hidden: yes
  }

  dimension: campania {
    type: string
    label: "Campaña"
    description: "Nombre de la campaña de Salesforce"
    sql: ${TABLE}.campania ;;
  }

  dimension: estado {
    type: string
    label: "Estado"
    description: "Estado geográfico del proyecto"
    sql: ${TABLE}.estado ;;
  }

  dimension: venta_por_piezas {
    type: yesno
    label: "¿Venta por Piezas?"
    description: "Indica si es venta por piezas"
    sql: ${TABLE}.venta_por_piezas ;;
  }

  # =======================================
  # DIMENSIONES DE PROJECT__C
  # =======================================

  dimension: total_delivered_quantity_in_ton__c {
    type: number
    label: "Cantidad Entregada (Ton)"
    description: "Cantidad total entregada en toneladas"
    sql: ${TABLE}.Total_Delivered_Quantity_In_Ton__c ;;
    value_format_name: decimal_2
  }

  dimension: total_pending_quantity_in_ton__c {
    type: number
    label: "Cantidad Pendiente (Ton)"
    description: "Cantidad total pendiente en toneladas"
    sql: ${TABLE}.Total_Pending_Quantity_in_Ton__c ;;
    value_format_name: decimal_2
  }

  # =======================================
  # MEASURES - CONTEOS
  # =======================================

  measure: count {
    type: count
    label: "# Oportunidades"
    description: "Conteo total de oportunidades"
    drill_fields: [detail_oportunidad*]
  }

  measure: count_oportunidades_activas {
    type: count
    label: "# Oportunidades Activas"
    description: "Oportunidades que NO están en Closed Won ni Closed Lost"
    filters: [etapa: "-Closed Won,-Closed Lost"]
    drill_fields: [detail_oportunidad*]
  }

  measure: count_oportunidades_ganadas {
    type: count
    label: "# Oportunidades Ganadas"
    description: "Oportunidades en etapa Closed Won"
    filters: [etapa: "Closed Won"]
    drill_fields: [detail_oportunidad*]
  }

  measure: count_oportunidades_perdidas {
    type: count
    label: "# Oportunidades Perdidas"
    description: "Oportunidades en etapa Closed Lost"
    filters: [etapa: "Closed Lost"]
    drill_fields: [detail_oportunidad*]
  }

  measure: count_oportunidades_vencidas {
    type: count
    label: "# Oportunidades Vencidas"
    description: "Oportunidades con fecha de inicio anterior a hoy"
    filters: [es_oportunidad_vencida: "Yes"]
    drill_fields: [detail_oportunidad*]
  }

  measure: count_oportunidades_por_vencer {
    type: count
    label: "# Oportunidades Por Vencer"
    description: "Oportunidades con fecha de inicio en los próximos 7 días"
    filters: [es_oportunidad_por_vencer: "Yes"]
    drill_fields: [detail_oportunidad*]
  }

  # =======================================
  # MEASURES - VOLÚMENES
  # =======================================

  measure: total_volumen {
    type: sum
    label: "Volumen Total"
    description: "Suma total del volumen de todas las oportunidades (toneladas)"
    sql: ${volumen} ;;
    value_format_name: decimal_2
    drill_fields: [detail_volumen*]
  }

  measure: total_volumen_ganado {
    type: sum
    label: "Volumen Ganado"
    description: "Suma del volumen de oportunidades ganadas (Closed Won)"
    sql: ${volumen_ganado} ;;
    value_format_name: decimal_2
    drill_fields: [detail_volumen*]
  }

  measure: total_volumen_perdido {
    type: sum
    label: "Volumen Perdido"
    description: "Suma del volumen de oportunidades perdidas (Closed Lost)"
    sql: ${volumen_perdido} ;;
    value_format_name: decimal_2
    drill_fields: [detail_volumen*]
  }

  measure: total_volumen_activo {
    type: sum
    label: "Volumen Activo"
    description: "Suma del volumen de oportunidades activas (no cerradas)"
    sql: ${volumen_activo} ;;
    value_format_name: decimal_2
    drill_fields: [detail_volumen*]
  }

  measure: promedio_volumen {
    type: average
    label: "Promedio Volumen"
    description: "Promedio de volumen por oportunidad"
    sql: ${volumen} ;;
    value_format_name: decimal_2
  }

  # =======================================
  # MEASURES - KPIs DE NEGOCIO
  # =======================================

  measure: tasa_conversion {
    type: number
    label: "% Conversión"
    description: "Tasa de conversión (Ganadas / Total de cerradas)"
    sql: SAFE_DIVIDE(${count_oportunidades_ganadas}, ${count_oportunidades_ganadas} + ${count_oportunidades_perdidas}) ;;
    value_format_name: percent_2
  }

  measure: pct_bateo_acumulado {
    type: number
    label: "% Bateo Acumulado"
    description: "Porcentaje de bateo: Volumen Ganado / (Volumen Ganado + Volumen Perdido)"
    sql: SAFE_DIVIDE(
          ${total_volumen_ganado},
          ${total_volumen_ganado} + ${total_volumen_perdido}
        ) ;;
    value_format_name: percent_2
    html:
    {% if value >= 0.7 %}
      <span style="color: #0F9D58; font-weight: bold;">{{ rendered_value }}</span>
    {% elsif value >= 0.5 %}
      <span style="color: #F4B400; font-weight: bold;">{{ rendered_value }}</span>
    {% else %}
      <span style="color: #DB4437; font-weight: bold;">{{ rendered_value }}</span>
    {% endif %} ;;
  }

  measure: ticket_promedio_ganado {
    type: number
    label: "Ticket Promedio Ganado"
    description: "Volumen promedio por oportunidad ganada"
    sql: SAFE_DIVIDE(${total_volumen_ganado}, NULLIF(${count_oportunidades_ganadas}, 0)) ;;
    value_format_name: decimal_2
  }

  measure: promedio_probabilidad_cierre {
    type: average
    label: "% Cierre Promedio"
    description: "Promedio de probabilidad de cierre de oportunidades activas"
    sql: ${porcentaje_cierre} ;;
    filters: [etapa: "-Closed Won,-Closed Lost"]
    value_format_name: percent_0
  }

  measure: duracion_promedio_meses {
    type: average
    label: "Duración Promedio (Meses)"
    description: "Duración promedio de proyectos en meses"
    sql: ${duracion_meses} ;;
    value_format_name: decimal_1
  }

  # =======================================
  # MEASURES - CANTIDAD DE PROYECTOS
  # =======================================

  measure: total_cantidad_entregada {
    type: sum
    label: "Total Cantidad Entregada (Ton)"
    description: "Suma de cantidad entregada en toneladas (Project__c)"
    sql: ${total_delivered_quantity_in_ton__c} ;;
    value_format_name: decimal_2
  }

  measure: total_cantidad_pendiente {
    type: sum
    label: "Total Cantidad Pendiente (Ton)"
    description: "Suma de cantidad pendiente en toneladas (Project__c)"
    sql: ${total_pending_quantity_in_ton__c} ;;
    value_format_name: decimal_2
  }

  # =======================================
  # DRILL FIELDS
  # =======================================

  set: detail_oportunidad {
    fields: [
      id_oportunidad,
      opportunity_name,
      cuenta,
      nombre_comercial,
      etapa_traducida,
      tipo_de_negocio_agrupado,
      fecha_inicio_date,
      fecha_cierre_date,
      volumen,
      porcentaje_cierre,
      resultado_oportunidad
    ]
  }

  set: detail_volumen {
    fields: [
      id_oportunidad,
      opportunity_name,
      cuenta,
      tipo_de_negocio_agrupado,
      etapa_traducida,
      volumen,
      total_volumen_ganado,
      total_volumen_perdido,
      total_volumen_activo
    ]
  }

  set: detail_comercial {
    fields: [
      nombre_comercial,
      count,
      total_volumen,
      total_volumen_ganado,
      pct_bateo_acumulado,
      tasa_conversion
    ]
  }
}
