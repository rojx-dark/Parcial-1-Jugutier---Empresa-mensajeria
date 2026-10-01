 defmodule Validacion do
  @moduledoc """
  Validación de los servicios registrados por los repartidores.

  Los servicios se revisan en el orden exigido y, si incumplen varias
  reglas, solo se reporta la primera.
  """

  @dias 1..6

  @doc """
  Valida un servicio.

  ## Parámetros

  - `servicio`: mapa con `:repartidor`, `:zona`, `:dia`, `:kilometros` y `:retraso`.
  - `repartidores`: lista de repartidores, cada uno con `:codigo`.
  - `zonas`: lista de zonas, cada una con `:id`.

  ## Retorno

  `{:ok, servicio}` si cumple las cinco reglas, o `{:error, motivo}`
  con el primer motivo incumplido.
  """
  def validar_servicio(servicio, repartidores, zonas) do
    with :ok <- validar_repartidor(servicio, repartidores),
         :ok <- validar_zona(servicio, zonas),
         :ok <- validar_dia(servicio),
         :ok <- validar_kilometros(servicio),
         :ok <- validar_retraso(servicio) do
      {:ok, servicio}
    end
  end

  # Regla 1: el repartidor debe existir.
  defp validar_repartidor(servicio, repartidores) do
    codigo = Map.get(servicio, :repartidor)

    if Enum.any?(repartidores, fn repartidor -> repartidor.codigo == codigo end) do
      :ok
    else
      {:error, :repartidor_desconocido}
    end
  end

  # Regla 2: la zona debe existir.
  defp validar_zona(servicio, zonas) do
    id = Map.get(servicio, :zona)

    if Enum.any?(zonas, fn zona -> zona.id == id end) do
      :ok
    else
      {:error, :zona_desconocida}
    end
  end

  # Regla 3: el día debe ser un entero entre 1 y 6.
  defp validar_dia(servicio) do
    dia = Map.get(servicio, :dia)

    if is_integer(dia) and dia in @dias do
      :ok
    else
      {:error, :dia_invalido}
    end
  end
end
