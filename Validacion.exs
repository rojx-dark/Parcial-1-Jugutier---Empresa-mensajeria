defmodule Validacion do
  @moduledoc """
  Validación de los servicios registrados por los repartidores.

  Los servicios se revisan en el orden exigido y, si incumplen varias
  reglas, solo se reporta la primera.

  Todas las funciones de este módulo son puras: no leen ni imprimen nada.
  """

  # -----------------------------------
  # Parámetros de validación
  # -----------------------------------

  @dias 1..6
  @max_km_servicio 45
  @min_retraso -30
  @max_retraso 180

  # -----------------------------------
  # Funciones públicas
  # -----------------------------------

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

  # -----------------------------------
  # Reglas individuales (privadas)
  # -----------------------------------

  # Regla 1: el repartidor debe existir.
  defp validar_repartidor(servicio, repartidores) do
    codigo = Map.get(servicio, :repartidor)
    coincidencias = Enum.filter(repartidores, fn repartidor -> repartidor.codigo == codigo end)

    # Si la lista de coincidencias no está vacía, el repartidor existe
    if coincidencias != [] do
      :ok
    else
      {:error, :repartidor_desconocido}
    end
  end

  # Regla 2: la zona debe existir.
  defp validar_zona(servicio, zonas) do
    id = Map.get(servicio, :zona)
    coincidencias = Enum.filter(zonas, fn zona -> zona.id == id end)

    # Si la lista de coincidencias no está vacía, la zona existe
    if coincidencias != [] do
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

  # Regla 4: los kilómetros deben ser un número mayor que 0 y máximo 45.
  # Se usa Map.get para no fallar si falta la clave.
  defp validar_kilometros(servicio) do
    kilometros = Map.get(servicio, :kilometros)

    if is_number(kilometros) and kilometros > 0 and kilometros <= @max_km_servicio do
      :ok
    else
      {:error, :kilometros_fuera_de_rango}
    end
  end

  # Regla 5: el retraso debe ser numérico y estar entre -30 y 180 minutos.
  defp validar_retraso(servicio) do
    retraso = Map.get(servicio, :retraso)

    if is_number(retraso) and retraso >= @min_retraso and retraso <= @max_retraso do
      :ok
    else
      {:error, :retraso_invalido}
    end
  end
end
