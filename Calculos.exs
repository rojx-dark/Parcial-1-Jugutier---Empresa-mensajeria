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
   --------------------------------------------------
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
      dias_trabajados =
        servicios_validos
        |> Enum.filter(fn s -> s.repartidor == repartidor.codigo end)
        |> Enum.map(& &1.dia)
        |> Enum.uniq()
        |> length()

      dias_trabajados * Validacion.alquiler_bicileta()
    else
      0
    end
  end
end
