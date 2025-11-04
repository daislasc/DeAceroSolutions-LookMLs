# 📦 LookML Package - Deacero Solutions

Este paquete contiene todos los modelos LookML desarrollados para Looker en el proyecto Deacero Solutions.

## 📁 Estructura

```
LookML/
├── README.md                    # Este archivo
└── SalesforceOpps/              # Modelo de Oportunidades de Salesforce
    ├── salesforce_opportunities.view
    ├── sf_prj_opps.model
    ├── README_LOOKML.md
    ├── IMPLEMENTATION_SUMMARY.md
    ├── _salesforce_opportunities.yml
    ├── consulta_clasificacion_salesforce.sql
    ├── consulta_clasificacion_funcional.sql
    └── INDEX.md
```

## 🚀 Cómo usar este paquete

### 1. Mover a tu nuevo proyecto
```bash
# Copiar toda la carpeta LookML a tu nuevo proyecto
cp -r LookML/ /ruta/a/nuevo/proyecto/
```

### 2. Instalar en Looker
Los archivos `.view` y `.model` deben copiarse a tu repositorio Git de Looker:

```bash
# Estructura típica de Looker
your-looker-repo/
├── models/
│   └── sf_prj_opps.model
└── views/
    └── salesforce_opportunities.view
```

### 3. Crear la tabla fuente en BigQuery
Ejecuta uno de los queries SQL:
- `consulta_clasificacion_salesforce.sql` (versión completa)
- `consulta_clasificacion_funcional.sql` (versión optimizada)

```sql
CREATE OR REPLACE TABLE mart_udn_das.salesforce_opportunities AS (
  -- Pegar contenido del SQL aquí
)
```

### 4. Configurar conexión en Looker
En el archivo `.model`, ajustar:
```lookml
connection: "tu_conexion_bigquery"
```

## 📚 Documentación

Cada subcarpeta contiene su propia documentación:
- `README_LOOKML.md`: Guía completa del modelo
- `IMPLEMENTATION_SUMMARY.md`: Resumen ejecutivo
- `INDEX.md`: Lista de archivos y su propósito

## 🔧 Requisitos

- **Looker**: Versión 7.0+
- **BigQuery**: Proyecto con datos de Salesforce (vía Datastream)
- **dbt** (opcional): Para gestionar la tabla fuente
- **Salesforce**: Objetos requeridos: Opportunity, Account, User, Project__c, Campaign, OpportunityFieldHistory

## 📞 Soporte

**Owner**: Equipo de Analytics - Deacero Solutions  
**Fecha de Creación**: 3 de Noviembre, 2025  
**Versión**: 1.0

---

## 📦 Proyectos Incluidos

### 1. **SalesforceOpps** ✅
- **Descripción**: Modelo analítico completo de oportunidades de Salesforce
- **Estado**: Producción Ready
- **Archivos**: 7
- **Líneas de Código**: ~1,600+
- **Features**: 
  - 60+ dimensiones
  - 25+ measures
  - HTML formatting
  - Access grants
  - Cache strategy

---

## 🎯 Próximos Proyectos (Roadmap)

### 2. **SalesforceProjects** (Planificado)
- Modelo específico para Project__c
- Integración con sistema comercial (Kraken/Masterview)

### 3. **SalesforceAccounts** (Planificado)
- Análisis de cuentas y clientes
- Segmentación de clientes

### 4. **SalesforceExecutive** (Planificado)
- Dashboard ejecutivo consolidado
- KPIs de alto nivel

---

**📦 Package Version**: 1.0.0  
**📅 Last Updated**: 2025-11-03

