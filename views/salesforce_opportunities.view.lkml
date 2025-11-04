# The name of this view in Looker is "Salesforce Opportunities"
view: salesforce_opportunities {
  # The sql_table_name parameter indicates the underlying database table
  # to be used for all fields in this view.
  sql_table_name: `mart_udn_das.salesforce_opportunities` ;;
  drill_fields: [id_oportunidad]

  # This primary key is the unique key for this table in the underlying database.
  # You need to define a primary key in a view in order to join to other views.

  dimension: id_oportunidad {
    primary_key: yes
    type: string
    sql: ${TABLE}.id_oportunidad ;;
  }
    # Here's what a typical dimension looks like in LookML.
    # A dimension is a groupable field that can be used to filter query results.
    # This dimension will be called "Alerta Amarilla" in Explore.

  dimension: alerta_amarilla {
    type: string
    sql: ${TABLE}.alerta_amarilla ;;
  }

  dimension: alerta_roja {
    type: string
    sql: ${TABLE}.alerta_roja ;;
  }

  dimension: campania {
    type: string
    sql: ${TABLE}.campania ;;
  }

  dimension: campania_id {
    type: string
    sql: ${TABLE}.campania_id ;;
  }

  dimension: comercial_id {
    type: string
    sql: ${TABLE}.comercial_id ;;
  }

  dimension: commercial_system_id__c {
    type: string
    sql: ${TABLE}.Commercial_System_ID__c ;;
  }

  dimension: cuenta {
    type: string
    sql: ${TABLE}.cuenta ;;
  }

  dimension: duracion_meses {
    type: number
    sql: ${TABLE}.duracion_meses ;;
  }

  dimension: es_oportunidad_por_vencer {
    type: number
    sql: ${TABLE}.es_oportunidad_por_vencer ;;
  }

  dimension: es_oportunidad_vencida {
    type: number
    sql: ${TABLE}.es_oportunidad_vencida ;;
  }

  dimension: estado {
    type: string
    sql: ${TABLE}.estado ;;
  }

  dimension: etapa {
    type: string
    sql: ${TABLE}.etapa ;;
  }

  dimension: etapa_traducida {
    type: string
    sql: ${TABLE}.etapa_traducida ;;
  }
  # Dates and timestamps can be represented in Looker using a dimension group of type: time.
  # Looker converts dates and timestamps to the specified timeframes within the dimension group.

  dimension_group: fecha_captura {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}.fecha_captura ;;
  }

  dimension_group: fecha_cierre {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}.fecha_cierre ;;
  }

  dimension_group: fecha_creacion {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    datatype: datetime
    sql: ${TABLE}.fecha_creacion ;;
  }

  dimension_group: fecha_fin {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}.fecha_fin ;;
  }

  dimension_group: fecha_final {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    datatype: datetime
    sql: ${TABLE}.fecha_final ;;
  }

  dimension_group: fecha_final_estatus_abierto {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    datatype: datetime
    sql: ${TABLE}.fecha_final_estatus_abierto ;;
  }

  dimension_group: fecha_inicio {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}.fecha_inicio ;;
  }

  dimension: lista_fechas_captura_oportunidad_proyecto {
    type: string
    sql: ${TABLE}.lista_fechasCaptura_oportunidad_proyecto ;;
  }

  dimension: lista_proyectos_oportunidad {
    type: string
    sql: ${TABLE}.lista_proyectos_oportunidad ;;
  }

  dimension: nombre_comercial {
    type: string
    sql: ${TABLE}.nombre_comercial ;;
  }

  dimension: opportunity_name {
    type: string
    sql: ${TABLE}.opportunity_name ;;
  }

  dimension: porcentaje_cierre {
    type: number
    sql: ${TABLE}.porcentaje_cierre ;;
  }

  dimension: project_id {
    type: string
    sql: ${TABLE}.project_id ;;
  }

  dimension: project_name {
    type: string
    sql: ${TABLE}.project_name ;;
  }

  dimension: resultado_oportunidad {
    type: string
    sql: ${TABLE}.resultado_oportunidad ;;
  }

  dimension: subetapa {
    type: string
    sql: ${TABLE}.subetapa ;;
  }

  dimension: tipo_de_negocio_agrupado {
    type: string
    sql: ${TABLE}.tipo_de_negocio_agrupado ;;
  }

  dimension: tipo_mercado {
    type: string
    sql: ${TABLE}.tipo_mercado ;;
  }

  dimension: tipo_negocio {
    type: string
    sql: ${TABLE}.tipo_negocio ;;
  }

  dimension: tipo_negocio_grupos {
    type: string
    sql: ${TABLE}.tipo_negocio_grupos ;;
  }

  dimension: tipo_obra {
    type: string
    sql: ${TABLE}.tipo_obra ;;
  }

  dimension: total_delivered_quantity_in_ton__c {
    type: number
    sql: ${TABLE}.Total_Delivered_Quantity_In_Ton__c ;;
  }

  dimension: total_pending_quantity_in_ton__c {
    type: number
    sql: ${TABLE}.Total_Pending_Quantity_in_Ton__c ;;
  }

  dimension: venta_por_piezas {
    type: yesno
    sql: ${TABLE}.venta_por_piezas ;;
  }

  dimension: volumen {
    type: number
    sql: ${TABLE}.volumen ;;
  }

  dimension: volumen_activo {
    type: number
    sql: ${TABLE}.volumen_activo ;;
  }

  dimension: volumen_ganado {
    type: number
    sql: ${TABLE}.volumen_ganado ;;
  }

  dimension: volumen_perdido {
    type: number
    sql: ${TABLE}.volumen_perdido ;;
  }
  measure: count {
    type: count
    drill_fields: [id_oportunidad, project_name, opportunity_name]
  }
}
