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
end
