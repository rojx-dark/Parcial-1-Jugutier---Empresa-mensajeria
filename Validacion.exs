# Integrantes: ______

defmodule Validacion do
  @moduledoc """
  Validación de los servicios registrados por los repartidores.

  Los servicios se revisan en el orden exigido y, si incumplen varias
  reglas, solo se reporta la primera.
  """

  @dias 1..6
  @tarifa_base 2_500
  @meta_diaria_km 500
  @max_km_servicio 45
  @km_bonificacion 80
  @bonificacion_dia 15_000
  @alquiler_bicicleta 10_000

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

  @doc """
  Valida todos los servicios y los separa en válidos y rechazados.

  ## Parámetros

  - `servicios`: lista de servicios sin validar.
  - `repartidores`: lista de repartidores, cada uno con `:codigo`.
  - `zonas`: lista de zonas, cada una con `:id`.

  ## Retorno

  Una tupla `{validos, rechazados}`, donde `validos` es la lista de
  servicios válidos y `rechazados` es una lista de tuplas
  `{servicio, motivo}`.
  """

  def separar_servicios(servicios, repartidores, zonas) do
    resultados =
      Enum.map(servicios, fn servicio ->
        {servicio, validar_servicio(servicio, repartidores, zonas)}
      end)

    validos = for {_servicio, {:ok, servicio}} <- resultados, do: servicio
    rechazados = for {servicio, {:error, motivo}} <- resultados, do: {servicio, motivo}

    {validos, rechazados}
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

  # Regla 4: Los kilómetros son un número mayor que 0 y máximo 45

  defp validar_kilometros(servicio) do
    # CORREGIDO: Map.get en lugar de servicio.kilometros, para no fallar si falta la clave
    kilometros = Map.get(servicio, :kilometros)
    valido = is_number(kilometros) and kilometros > 0 and kilometros <= @max_km_servicio

    if valido do

      :ok
    else
      {:error, :kilometros_fuera_de_rango}
    end
  end

  # Regla 5: El retraso es numérico y se encuentra entre -30 y 180 minutos

  defp validar_retraso(servicio) do

    retraso = Map.get(servicio, :retraso)
    valido = is_number(retraso) and retraso >= -30 and retraso <= 180

    if valido do
     
      :ok
    else
      {:error, :retraso_invalido}
    end
  end

  # Funciones Publicas de acceso a constantes

  @doc "Retorna la tarifa base por kilómetro"
  def tarifa_base, do: @tarifa_base

  @doc "Retorna la meta diaria de kilómetros de la empresa"
  def meta_diaria_km, do: @meta_diaria_km

  @doc "Retorna el máximo de kilómetros permitido por servicio"
  def max_km_servicio, do: @max_km_servicio

  @doc "Retorna los kilómetros necesarios para la bonificación diaria"
  def km_bonificacion, do: @km_bonificacion

  @doc "Retorna el valor de la bonificación diaria"
  def bonificacion_dia, do: @bonificacion_dia

  @doc "Retorna el costo de alquiler de bicicleta por día trabajado"
  def alquiler_bicicleta, do: @alquiler_bicicleta
end
