# Carga todos los módulos en orden (dependencias primero)
Code.require_file("Util2.exs", __DIR__)
Code.require_file("Datos.exs", __DIR__)
Code.require_file("Validacion.exs", __DIR__)
Code.require_file("Calculos.exs", __DIR__)
Code.require_file("Reportes.exs", __DIR__)
Code.require_file("Interaccion.exs", __DIR__)
Code.require_file("Investigacion.exs", __DIR__)

defmodule Main do
  @moduledoc """
  Punto de entrada del programa. Orquesta la ejecución completa:
    1. Carga los datos
    2. Valida todos los servicios
    3. Solicita el servicio adicional
    4. Calcula la liquidación
    5. Genera los 8 reportes en orden
    6. Muestra el comprobante de un repartidor
    7. Ejecuta la investigación (ranking, Map.merge/3 y mediciones)

  Este módulo no contiene lógica de negocio: solo coordina a los demás.
  """

  def main do
    # ------------------------------------------------
    # PASO 1: Carga de datos
    # ------------------------------------------------
    repartidores = Datos.repartidores()
    zonas = Datos.zonas()
    servicios = Datos.servicios()

    # ------------------------------------------------
    # PASO 2: Validación de todos los servicios
    # ------------------------------------------------
    # separar_servicios/3 aplica validar_servicio/3 a cada servicio y devuelve:
    #   validos    = lista de servicios (mapas) que pasaron la validación
    #   rechazados = lista de tuplas {servicio, motivo} de los rechazados
    {validos, rechazados} = Validacion.separar_servicios(servicios, repartidores, zonas)

    # ------------------------------------------------
    # PASO 3: Servicio adicional (interacción)
    # ------------------------------------------------
    validos = Interaccion.agregar_servicio_adicional(validos, repartidores, zonas)

    # ------------------------------------------------
    # PASO 4: Precalcula la liquidación (se usa en varios reportes)
    # ------------------------------------------------
    liquidaciones = Calculos.calcular_liquidacion_todos(repartidores, validos)

    # ------------------------------------------------
    # PASO 5: Genera los 8 reportes EN ORDEN
    # ------------------------------------------------
    Reportes.r1(rechazados)
    Reportes.r2(validos, zonas)

    # r3 retorna el mapa de km por día, se guarda para la investigación
    km_por_dia = Reportes.r3(validos)

    Reportes.r4(liquidaciones)
    Reportes.r5(validos, repartidores)
    Reportes.r6(validos, repartidores)
    Reportes.r7(liquidaciones)
    Reportes.r8(validos, repartidores, zonas)

    # ------------------------------------------------
    # PASO 6: Comprobante del repartidor
    # ------------------------------------------------
    Interaccion.mostrar_comprobante(validos, repartidores)

    # ------------------------------------------------
    # PASO 7: Investigación
    # ------------------------------------------------
    Investigacion.mostrar_ranking(liquidaciones)

    empresa_aliada = %{1 => 580.5, 2 => 430, 3 => 510, 5 => 625, 7 => 180}

    Util2.mostrar("\n=== Investigación C2: Map.merge/3 ===", :mensaje)
    combinado = Investigacion.combinar_km_diarios(km_por_dia, empresa_aliada)
    IO.inspect(combinado, label: "Km combinados con empresa aliada")

    Investigacion.medir_tiempos(validos, repartidores, zonas)
  end
end

# Ejecuta el programa
Main.main()
 