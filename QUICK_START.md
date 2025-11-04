# ⚡ Quick Start Guide - LookML Package

## 🚀 Instalación en 5 Minutos

### 1️⃣ Crear Tabla en BigQuery (2 min)

```sql
-- Ejecutar en BigQuery Console
CREATE OR REPLACE TABLE mart_udn_das.salesforce_opportunities AS (
  -- Copiar contenido de: SalesforceOpps/consulta_clasificacion_salesforce.sql
  -- Pegar aquí el contenido completo
);

-- Verificar
SELECT COUNT(*) FROM mart_udn_das.salesforce_opportunities;
```

---

### 2️⃣ Copiar Archivos a Looker (1 min)

```bash
# En tu repo Git de Looker
cd your-looker-repo

# Copiar view
cp /path/to/LookML/SalesforceOpps/salesforce_opportunities.view views/

# Copiar model
cp /path/to/LookML/SalesforceOpps/sf_prj_opps.model models/
```

---

### 3️⃣ Ajustar Configuración (1 min)

**Archivo**: `models/sf_prj_opps.model`

```lookml
# Línea 2: Cambiar a tu conexión
connection: "TU_CONEXION_BIGQUERY"  # ← CAMBIAR ESTO

# Líneas 48-60: Ajustar access grants (opcional)
access_grant: admin_access {
  user_attribute: department  # o 'role', según tu config
  allowed_values: [ "Analytics", "Admin", "IT" ]
}
```

**Archivo**: `views/salesforce_opportunities.view` (solo si cambió el nombre de la tabla)

```lookml
# Línea 5: Verificar tabla
sql_table_name: `PROYECTO.DATASET.salesforce_opportunities` ;;
```

---

### 4️⃣ Validar en Looker (1 min)

```bash
# Git
git add views/salesforce_opportunities.view models/sf_prj_opps.model
git commit -m "feat: Add Salesforce Opportunities LookML model"
git push origin main

# En Looker UI
1. Ir a Develop → [Tu proyecto]
2. Presionar Ctrl+S o ⌘S para validar
3. Si hay errores, revisar en la consola
4. Hacer "Commit & Push to Production"
```

---

### 5️⃣ Probar Explore (30 seg)

```bash
# En Looker
1. Ir a Explore → "Oportunidades Salesforce"
2. Seleccionar:
   - Dimension: nombre_comercial
   - Measure: total_volumen
   - Filter: fecha_creacion_year = "Este año"
3. Run

¡Debería mostrar datos! 🎉
```

---

## 📊 Primera Visualización

### Query Ejemplo: % Bateo por Comercial

1. **Explore**: Oportunidades Salesforce
2. **Dimension**: `nombre_comercial`
3. **Measures**: 
   - `count_oportunidades_ganadas`
   - `count_oportunidades_perdidas`
   - `pct_bateo_acumulado`
4. **Filtros**: 
   - `fecha_creacion_year` = "2025"
   - `tipo_de_negocio_agrupado` != "NULL"
5. **Visualización**: Table con formato condicional

**Resultado**: Ver efectividad de cada comercial con % de bateo coloreado (Verde ≥70%, Amarillo ≥50%, Rojo <50%)

---

## 🆘 Troubleshooting

### ❌ Error: "Could not find table"
```
✅ Solución:
1. Verificar que ejecutaste el SQL en BigQuery
2. Verificar el nombre correcto: mart_udn_das.salesforce_opportunities
3. Verificar permisos de lectura en BigQuery
```

### ❌ Error: "Invalid connection"
```
✅ Solución:
1. Revisar models/sf_prj_opps.model línea 2
2. Cambiar connection: "TU_CONEXION_BIGQUERY"
3. Validar que la conexión existe en Admin → Connections
```

### ❌ Error: "Field X does not exist"
```
✅ Solución:
1. Verificar que la tabla tiene todas las columnas
2. Ejecutar: SELECT * FROM mart_udn_das.salesforce_opportunities LIMIT 1
3. Comparar con _salesforce_opportunities.yml
```

### ❌ No aparece el Explore
```
✅ Solución:
1. Verificar que hiciste commit & push
2. Ir a Admin → Projects → Development Mode (activar)
3. Refresh la página
4. Buscar en Explore → "Oportunidades Salesforce"
```

---

## 📚 Documentación Completa

Para más detalles, consultar:

| Documento | Ubicación | Para qué |
|-----------|-----------|----------|
| README_LOOKML.md | SalesforceOpps/ | Guía completa |
| INDEX.md | SalesforceOpps/ | Lista de archivos |
| IMPLEMENTATION_SUMMARY.md | SalesforceOpps/ | Resumen ejecutivo |
| _salesforce_opportunities.yml | SalesforceOpps/ | Schema de datos |

---

## ✅ Checklist Post-Instalación

- [ ] Tabla creada en BigQuery
- [ ] Archivos copiados a Looker repo
- [ ] Conexión ajustada en model
- [ ] Git commit & push realizado
- [ ] Validación LookML sin errores
- [ ] Explore visible y funcional
- [ ] Primera query ejecutada correctamente
- [ ] Dashboard piloto creado
- [ ] Equipo notificado

---

## 🎯 Próximos Pasos

1. **Crear Dashboard Ejecutivo**
   - Pipeline por etapa
   - % Bateo por comercial
   - Alertas de vencimiento
   - Volumen activo vs ganado

2. **Configurar Scheduled Deliveries**
   - Reporte semanal para gerentes
   - Alertas diarias de oportunidades vencidas

3. **Training al Equipo**
   - Sesión de 30 min con equipo de ventas
   - Mostrar cómo usar los filtros
   - Explicar KPIs principales

4. **Optimizaciones Futuras**
   - Agregar JOINs con Account, User separadas
   - Crear derived tables para cálculos complejos
   - Implementar persistent derived tables (PDT)

---

## 📞 Soporte

**Documentación**: Ver archivos en `SalesforceOpps/`  
**Owner**: Equipo de Analytics - Deacero Solutions  
**Versión**: 1.0

---

**⚡ Instalación completa en ~5 minutos** 🚀

