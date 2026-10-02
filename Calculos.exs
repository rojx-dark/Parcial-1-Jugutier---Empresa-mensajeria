# Integrantes: ______

defmodule Calculos do
  @moduledoc """
  Cálculos de la liquidación semanal: valor de los servicios,
  bonificaciones, alquiler de bicicleta y neto de cada repartidor.

  Todas las funciones son puras: reciben datos y devuelven resultados,
  sin leer del teclado ni imprimir.
  """

  # -----------------------------------
  # Parámetros del problema
  # -----------------------------------

  @tarifa_km 2_500
  @meta_diaria 500
  @km_bonificacion 80
  @bonificacion 15_000
  @alquiler_dia 10_000

  # -----------------------------------
  # Valor de un servicio
  # -----------------------------------

  @doc """
  Calcula el valor de un servicio válido.

  El valor inicial es kilómetros por tarifa base, y luego se ajusta
  según la puntualidad de la entrega.

  ## Parámetros

  - `servicio`: mapa con las claves `:kilometros` y `:retraso`.

  ## Retorno

  El valor del servicio, como número.

  ## Ejemplos

      Calculos.valor_servicio(%{kilometros: 18, retraso: 3})
      # => 45000.0

      Calculos.valor_servicio(%{kilometros: 10, retraso: -5})
      # => 27000.0
  """
  def valor_servicio(%{kilometros: km, retraso: retraso}) do
    km * @tarifa_km * factor_puntualidad(retraso)
  end

  # Factor de ajuste según el retraso en minutos:
  # hasta 0 -> +8 %, hasta 10 -> sin ajuste, hasta 30 -> -10 %, más de 30 -> -25 %.
  defp factor_puntualidad(retraso) do
    cond do
      retraso <= 0 -> 1.08
      retraso <= 10 -> 1.0
      retraso <= 30 -> 0.90
      true -> 0.75
    end
  end

  # --------------------------------------------------
  # 2. BONIFICACIÓN POR PRODUCTIVIDAD
  # --------------------------------------------------

  @doc """
  Calcula la bonificación diaria de un repartidor en un día específico.

  Recibe la lista de servicios válidos de UN solo repartidor en UN solo día.

  Regla:
    Si la suma de kilómetros >= 80 → bonificación de $15.000
    Si no                          → bonificación de $0

  Retorna un número (0 o 15_000).
  """
  def calcular_bonificacion_dia(servicios_del_dia) do
    km_totales =
      servicios_del_dia
      |> Enum.map(& &1.kilometros)
      |> Enum.sum()

    if km_totales >= Validacion.km_bonificacion() do
      Validacion.bonificacion_dia()
    else
      0
    end
  end

  # --------------------------------------------------
  # 3. ALQUILER DE BICICLETA
  # --------------------------------------------------

  @doc """
  Calcula el costo total de alquiler de bicicleta para un repartidor
  durante toda la semana.

  Recibe:
    - repartidor: el mapa del repartidor
    - servicios_validos: lista de servicios válidos (todos, no solo de ese rep.)

  Regla:
    Solo aplica si repartidor.bicicleta == true.
    Se cobra $10.000 por cada DÍA en el que tenga al menos 1 servicio válido.

  Retorna un número (el costo total de alquiler).
  """
  def calcular_alquiler(repartidor, servicios_validos) do
    if repartidor.bicicleta do
      servicios_rep = Enum.filter(servicios_validos, fn s -> s.repartidor == repartidor.codigo end)

      # Un día trabajado es un día (1..6) con al menos un servicio válido
      dias_trabajados =
        1..6
        |> Enum.filter(fn dia -> Enum.any?(servicios_rep, fn s -> s.dia == dia end) end)
        |> length()

      dias_trabajados * Validacion.alquiler_bicicleta()
    else
      0
    end
  end


  # --------------------------------------------------
  # 4. LIQUIDACIÓN POR REPARTIDOR
  # --------------------------------------------------

  @doc """
  Calcula la liquidación completa de un repartidor.

  Recibe:
    - repartidor: mapa del repartidor
    - servicios_validos: lista de TODOS los servicios válidos

  Retorna un mapa con:
    %{
      codigo:        String,
      nombre:        String,
      kilometros:    número total de km recorridos,
      valor_servicios: número total en pesos de sus servicios,
      bonificaciones:  número total de bonificaciones recibidas,
      alquiler:        número total descontado por bicicleta,
      neto:            valor_servicios + bonificaciones - alquiler
    }
  """
    def calcular_liquidacion(repartidor, servicios_validos) do
    servicios_rep = Enum.filter(servicios_validos, fn s -> s.repartidor == repartidor.codigo end)

    km_totales =
      servicios_rep
      |> Enum.map(& &1.kilometros)
      |> Enum.sum()

    total_servicios =
      servicios_rep
      |> Enum.map(&valor_servicio/1)
      |> Enum.sum()

    # La bonificación se calcula día por día; un día sin servicios da 0
    total_bonificaciones =
      1..6
      |> Enum.map(fn dia ->
        servicios_rep
        |> Enum.filter(fn s -> s.dia == dia end)
        |> calcular_bonificacion_dia()
      end)
      |> Enum.sum()

    alquiler = calcular_alquiler(repartidor, servicios_validos)
    neto = total_servicios + total_bonificaciones - alquiler

    %{
      codigo: repartidor.codigo,
      nombre: repartidor.nombre,
      kilometros: km_totales,
      valor_servicios: total_servicios,
      bonificaciones: total_bonificaciones,
      alquiler: alquiler,
      neto: neto
    }
  end

  @doc """
  Calcula la liquidación de TODOS los repartidores.

  Recibe:
    - repartidores: lista de todos los repartidores
    - servicios_validos: lista de todos los servicios válidos

  Retorna una lista de mapas (uno por repartidor), incluyendo
  los que no tienen servicios (sus valores numéricos deben ser 0).
  """
  def calcular_liquidacion_todos(repartidores, servicios_validos) do
    # Aplica calcular_liquidacion a cada repartidor

    Enum.map(repartidores, fn repartidor ->
      calcular_liquidacion(repartidor, servicios_validos)
    end)
  end

  # --------------------------------------------------
  # 5. DETALLE POR DÍA (para el comprobante R4 y comprobante)
  # --------------------------------------------------

  @doc """
  Calcula el detalle día a día de un repartidor.

  Recibe:
    - repartidor: mapa del repartidor
    - servicios_validos: lista de todos los servicios válidos

  Retorna una lista de mapas, uno por día trabajado (solo días con servicios válidos):
    %{
      dia:            número del día,
      kilometros:     km recorridos ese día,
      valor_servicios: valor de los servicios de ese día,
      bonificacion:   bonificación obtenida ese día
    }
  """
    def calcular_detalle_por_dia(repartidor, servicios_validos) do
    servicios_rep = Enum.filter(servicios_validos, fn s -> s.repartidor == repartidor.codigo end)

    # Se recorren los días en orden (1..6), así el resultado ya sale ordenado
    1..6
    |> Enum.map(fn dia ->
      {dia, Enum.filter(servicios_rep, fn s -> s.dia == dia end)}
    end)
    # Solo los días con al menos un servicio válido
    |> Enum.filter(fn {_dia, servicios_dia} -> servicios_dia != [] end)
    |> Enum.map(fn {dia, servicios_dia} ->
      %{
        dia: dia,
        kilometros: servicios_dia |> Enum.map(& &1.kilometros) |> Enum.sum(),
        valor_servicios: servicios_dia |> Enum.map(&valor_servicio/1) |> Enum.sum(),
        bonificacion: calcular_bonificacion_dia(servicios_dia)
      }
    end)
  end
    |> Util2.ordenar(:asc, & &1.dia)
  end
