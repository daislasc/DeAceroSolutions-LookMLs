# 📊 Salesforce Opportunities - LookML Model

## 📋 Descripción General

Este modelo LookML proporciona una vista analítica completa de las oportunidades de Salesforce, integrando datos de:
- **Opportunity** (Oportunidades)
- **Account** (Cuentas)
- **User** (Usuarios/Comerciales)
- **Project__c** (Proyectos custom)
- **Campaign** (Campañas)
- **OpportunityFieldHistory** (Historial de cambios de etapa)

## 🎯 Casos de Uso Principales

### 1. **Dashboard de Oportunidades**
- Seguimiento de pipeline de ventas
- Análisis de conversión y % de bateo
- Alertas de fechas vencidas o próximas
- Distribución por tipo de negocio (AP, HP, HV, MI)

### 2. **Análisis de Desempeño Comercial**
- Métricas por comercial
- Tasa de conversión por etapa
- Ticket promedio ganado
- Volumen activo vs ganado vs perdido

### 3. **Gestión de Proyectos**
- Tracking de proyectos asociados a oportunidades
- Cantidad entregada vs pendiente
- Duración promedio de proyectos
- Análisis por estado/región

### 4. **Reporting Ejecutivo**
- KPIs consolidados de ventas
- Tendencias mensuales/trimestrales
- Análisis de campañas
- Forecast y proyecciones

---

## 📁 Estructura de Archivos

```
models/Salesforce/
├── salesforce_opportunities.view    # Vista principal con dimensiones y measures
├── sf_prj_opps.model                # Modelo con explores y configuración
└── README_LOOKML.md                 # Esta documentación
```

---

## 🔑 Dimensiones Clave

### **Dimensiones de Negocio**
- `opportunity_name`: Nombre de la oportunidad
- `etapa` / `etapa_traducida`: Etapa actual (inglés/español)
- `tipo_de_negocio_agrupado`: Tipo de negocio (AP, HP, HV, MI, Otros)
- `resultado_oportunidad`: GANADO, PERDIDO, o en proceso

### **Dimensiones Temporales**
- `fecha_creacion`: Fecha de creación de la oportunidad
- `fecha_inicio`: Fecha de inicio del proyecto
- `fecha_cierre`: Fecha de cierre esperada
- `fecha_final`: Fecha cuando cambió a Closed Won/Lost/Discarded
- `fecha_final_estatus_abierto`: Fecha cuando cambió a New/Concurso/Cotización/Negotiation

### **Dimensiones de Relaciones**
- `cuenta`: Nombre de la cuenta
- `nombre_comercial`: Comercial owner
- `project_name`: Nombre del proyecto asociado
- `campania`: Campaña asociada

### **Alertas**
- `alerta_amarilla`: Fechas de inicio en próximos 7 días (⚠️ PRÓXIMO)
- `alerta_roja`: Fechas de inicio ya pasadas (🔴 VENCIDO)
- `estado_alerta_consolidado`: Estado consolidado (VENCIDO / PRÓXIMO / OK)

---

## 📊 Measures (Métricas) Clave

### **Conteos**
- `count`: Total de oportunidades
- `count_oportunidades_activas`: Oportunidades no cerradas
- `count_oportunidades_ganadas`: Oportunidades Closed Won
- `count_oportunidades_perdidas`: Oportunidades Closed Lost
- `count_oportunidades_vencidas`: Oportunidades con fecha pasada
- `count_oportunidades_por_vencer`: Oportunidades en próximos 7 días

### **Volúmenes**
- `total_volumen`: Suma total de volumen (toneladas)
- `total_volumen_ganado`: Volumen de oportunidades ganadas
- `total_volumen_perdido`: Volumen de oportunidades perdidas
- `total_volumen_activo`: Volumen de oportunidades activas
- `promedio_volumen`: Promedio de volumen por oportunidad

### **KPIs de Negocio**
- `tasa_conversion`: % de conversión (Ganadas / Total cerradas)
- `pct_bateo_acumulado`: % Bateo = Volumen Ganado / (Volumen Ganado + Perdido)
- `ticket_promedio_ganado`: Volumen promedio por oportunidad ganada
- `promedio_probabilidad_cierre`: % promedio de probabilidad de cierre
- `duracion_promedio_meses`: Duración promedio de proyectos

---

## 🎨 Características Especiales

### **1. HTML Formatting**
Las dimensiones tienen formato HTML condicional para mejor visualización:

```lookml
dimension: resultado_oportunidad {
  html: 
    {% if value == 'GANADO' %}
      <span style="color: #0F9D58; font-weight: bold;">✓ {{ value }}</span>
    {% elsif value == 'PERDIDO' %}
      <span style="color: #DB4437; font-weight: bold;">✗ {{ value }}</span>
    {% else %}
      <span style="color: #F4B400;">⏳ En Proceso</span>
    {% endif %} ;;
}
```

### **2. Drill Fields**
Tres sets de drill fields configurados:
- `detail_oportunidad`: Detalle completo de oportunidades
- `detail_volumen`: Enfocado en análisis de volumen
- `detail_comercial`: Análisis por comercial

### **3. Links a Salesforce**
Campos como `id_oportunidad` y `opportunity_name` tienen links directos a Salesforce:

```lookml
link: {
  label: "Ver en Salesforce"
  url: "https://deacero.lightning.force.com/lightning/r/Opportunity/{{ value }}/view"
  icon_url: "https://www.salesforce.com/favicon.ico"
}
```

### **4. Ordenamiento Lógico**
Dimensiones como `etapa` y `tipo_de_negocio_agrupado` tienen `order_by_field` para ordenamiento lógico (no alfabético).

---

## ⚙️ Configuración de Cache

### **Datagroups**

#### `sf_prj_opps_default_datagroup`
- Actualización: Diaria (6:00 AM)
- Max cache: 24 horas
- Uso: Reports estándar

#### `sf_prj_opps_hourly_datagroup`
- Actualización: Cada hora
- Max cache: 1 hora
- Uso: Dashboards ejecutivos en tiempo real

---

## 🔐 Access Grants (Control de Acceso)

### `admin_access`
Departamentos: Analytics, Admin, IT

### `sales_team_access`
Departamentos: Sales, Commercial, Analytics, Admin

### `executive_access`
Roles: Executive, Director, VP, C-Level

---

## 📈 Explores Disponibles

### **1. `salesforce_opportunities`** (Principal)
- **Descripción**: Análisis completo de oportunidades
- **Acceso**: sales_team_access
- **Cache**: Horario (1 hora)
- **Uso**: Dashboards operativos

### **2. `Análisis Comercial (Dashboard Ejecutivo)`**
- **Descripción**: Vista ejecutiva de métricas clave
- **Acceso**: executive_access (restringido)
- **Cache**: Horario (1 hora)
- **Uso**: Reporting ejecutivo

---

## 🚀 Ejemplos de Uso en Looker

### **Ejemplo 1: % Bateo por Comercial**
```
Dimension: nombre_comercial
Measure: pct_bateo_acumulado
Visualización: Bar Chart
Filtro: fecha_creacion_year = "2025"
```

### **Ejemplo 2: Pipeline por Etapa**
```
Dimension: etapa_traducida
Measure: count
Measure: total_volumen
Visualización: Funnel Chart
Filtro: etapa != "Closed Won", "Closed Lost"
```

### **Ejemplo 3: Oportunidades Vencidas y Por Vencer**
```
Dimension: estado_alerta_consolidado
Measure: count
Visualización: Single Value con alerta
Filtro: estado_alerta_consolidado != "OK"
```

### **Ejemplo 4: Análisis de Conversión por Tipo de Negocio**
```
Dimension: tipo_de_negocio_agrupado
Measure: count_oportunidades_ganadas
Measure: count_oportunidades_perdidas
Measure: tasa_conversion
Visualización: Table con formatos condicionales
```

---

## 🔄 Migración desde Looker Studio

Si estás migrando desde Looker Studio (Data Studio), ten en cuenta:

| Looker Studio | Looker (LookML) |
|---------------|-----------------|
| Calculated Fields | `dimension:` o `measure:` |
| Data Source | `sql_table_name:` |
| Conditional Formatting | `html:` parameter |
| Filtros | `filters:` en measures o SQL `WHERE` |
| Aggregations | `measure:` con `type:` |

---

## 📝 Mantenimiento

### **Actualizar la Tabla Fuente**
La tabla fuente se actualiza ejecutando:
```sql
CREATE OR REPLACE TABLE mart_udn_das.salesforce_opportunities AS (
  -- Query from consulta_clasificacion_funcional.sql
)
```

### **Actualizar el View**
Cuando se agreguen nuevos campos a la tabla:
1. Actualizar `salesforce_opportunities.view`
2. Agregar dimensión o measure correspondiente
3. Documentar el campo con `label:` y `description:`
4. Agregar a drill_fields si es relevante

### **Actualizar el Model**
Si se agregan nuevas tablas relacionadas:
1. Crear view `.lkml` para la nueva tabla
2. Agregar `join:` en el explore
3. Definir `relationship:` y `sql_on:`

---

## 🐛 Troubleshooting

### Error: "Unknown field X"
- Verificar que el campo existe en la tabla BigQuery
- Verificar spelling en `${TABLE}.campo_nombre`

### Medida retorna NULL
- Verificar que hay datos en los filtros aplicados
- Usar `SAFE_DIVIDE` o `NULLIF` para evitar divisiones por cero

### Cache no se actualiza
- Verificar el `sql_trigger` del datagroup
- Forzar clear cache desde Looker Admin

---

## 📚 Recursos Adicionales

- [Looker LookML Reference](https://cloud.google.com/looker/docs/reference/param-explore)
- [BigQuery SQL Reference](https://cloud.google.com/bigquery/docs/reference/standard-sql/query-syntax)
- [dbt + Looker Integration](https://docs.getdbt.com/docs/cloud/connect-data-platform/about-connections#looker)

---

## 👥 Contacto

**Owner**: Equipo de Analytics - Deacero Solutions  
**Última Actualización**: 2025-01-03  
**Versión**: 1.0

