efmodule Reportes do
  @moduledoc """
  Módulo que genera los 8 reportes del sistema.

  Los reportes se llaman en orden R1 -> R8 desde main.exs.
  Todas las funciones hacen IO (son IMPURAS), pero calculan con funciones puras.
  """

  @motivos [
    :repartidor_desconocido,
    :zona_desconocida,
    :dia_invalido,
    :kilometros_fuera_de_rango,
    :retraso_invalido
  ]

  # --------------------------------------------------
  # R1 — Servicios rechazados
  # --------------------------------------------------

  @doc """
  Muestra los servicios rechazados, el motivo de cada uno
  y la cantidad de rechazos por motivo.

  Recibe:
    - rechazados: lista de tuplas {servicio, motivo}, como la que
      devuelve Validacion.separar_servicios/3
  """
  def r1(rechazados) do
    mostrar("\n=== R1: Servicios rechazados ===")

    # Paso 1: muestra cada servicio con su motivo
    Enum.each(rechazados, fn {servicio, motivo} ->
      mostrar(
        "Repartidor: #{servicio.repartidor} | Zona: #{servicio.zona} | " <>
          "Día: #{servicio.dia} | Km: #{servicio.kilometros} | " <>
          "Retraso: #{servicio.retraso} -> #{motivo}"
      )
    end)

    # Paso 2 y 3: cuenta cuántos rechazos hay por cada motivo
    mostrar("\nRechazos por motivo:")

    Enum.each(@motivos, fn motivo ->
      cantidad = length(Enum.filter(rechazados, fn {_servicio, m} -> m == motivo end))
      mostrar("  #{motivo}: #{cantidad}")
    end)
  end

  # --------------------------------------------------
  # R2 — Kilómetros por zona y densidad
  # --------------------------------------------------

  @doc """
  Muestra los kilómetros recorridos en cada zona y la densidad de recorrido
  (km / área), ordenados de mayor a menor densidad.

  Una zona sin servicios válidos aparece con 0 km.

  Recibe:
    - servicios_validos: lista de servicios válidos
    - zonas: lista de todas las zonas

  Fórmula densidad: km_zona / zona.area
  """
  def r2(servicios_validos, zonas) do
    mostrar("\n=== R2: Kilómetros por zona y densidad ===")

    # Paso 1 y 2: para cada zona suma los km de sus servicios y calcula la densidad
    zonas
    |> Enum.map(fn zona ->
      km =
        servicios_validos
        |> Enum.filter(fn s -> s.zona == zona.id end)
        |> Enum.map(& &1.kilometros)
        |> Enum.sum()

      %{zona: zona, kilometros: km, densidad: km / zona.area}
    end)
    # Paso 3: ordena de mayor a menor densidad
    |> Util2.ordenar(:desc, & &1.densidad)
    # Paso 4: imprime cada zona con sus datos
    |> Enum.each(fn fila ->
      mostrar(
        "#{fila.zona.id} #{fila.zona.nombre} | " <>
          "Km: #{fila.kilometros} | Área: #{fila.zona.area} km² | " <>
          "Densidad: #{Float.round(fila.densidad, 2)} km/km²"
      )
    end)
  end

  # --------------------------------------------------
  # R3 — Kilómetros por día y meta
  # --------------------------------------------------

  @doc """
  Muestra los kilómetros recorridos por TODA la empresa en cada uno de
  los 6 días e indica si se alcanzó la meta de 500 km.

  Al final indica:
    - ¿Se alcanzó la meta TODOS los días?
    - ¿Se alcanzó la meta AL MENOS UN día?

  Recibe:
    - servicios_validos: lista de todos los servicios válidos

  Retorna el mapa de km por día (necesario para la investigación):
    %{1 => 620.5, 2 => 480.0, ...}
  """
  def r3(servicios_validos) do
    mostrar("\n=== R3: Kilómetros por día y meta ===")

    meta = Calculos.meta_diaria()

    # Paso 1 y 2: para los 6 días suma los km (0 si no hay servicios)
    km_por_dia =
      for dia <- 1..6, into: %{} do
        km =
          servicios_validos
          |> Enum.filter(fn s -> s.dia == dia end)
          |> Enum.map(& &1.kilometros)
          |> Enum.sum()

        {dia, km}
      end

    # Paso 3: imprime cada día con sus km y si alcanzó la meta
    Enum.each(1..6, fn dia ->
      km = Map.get(km_por_dia, dia)
      estado = if km >= meta, do: "meta alcanzada", else: "meta NO alcanzada"
      mostrar("Día #{dia}: #{km} km -> #{estado}")
    end)

    # Paso 4: ¿todos los días cumplen la meta? Sí, si ningún día queda por debajo
    dias_bajo_meta = Enum.filter(km_por_dia, fn {_dia, km} -> km < meta end)
    todos = dias_bajo_meta == []
    # Paso 5: ¿al menos un día cumple la meta? Sí, si hay algún día que la alcanzó
    dias_con_meta = Enum.filter(km_por_dia, fn {_dia, km} -> km >= meta end)
    alguno = dias_con_meta != []

    mostrar("¿Meta alcanzada todos los días? #{if todos, do: "Sí", else: "No"}")
    mostrar("¿Meta alcanzada al menos un día? #{if alguno, do: "Sí", else: "No"}")

    # Paso 6: retorna el mapa %{dia => km_totales}
    km_por_dia
  end

  # --------------------------------------------------
  # R4 — Liquidación de todos los repartidores
  # --------------------------------------------------

  @doc """
  Muestra la liquidación de todos los repartidores, numerada y ordenada
  de mayor a menor por neto.

  Recibe:
    - liquidaciones: lista de mapas retornada por
      Calculos.calcular_liquidacion_todos/2
  """
  def r4(liquidaciones) do
    mostrar("\n=== R4: Liquidación de repartidores ===")

    # Paso 1: ordena liquidaciones por neto desc
    # Paso 2 y 3: Enum.reduce lleva el número de posición como acumulador
    # (empieza en 1 y sube de a uno) mientras imprime cada repartidor
    liquidaciones
    |> Util2.ordenar(:desc, & &1.neto)
    |> Enum.reduce(1, fn l, posicion ->
      mostrar(
        "#{posicion}. #{l.nombre} (#{l.codigo}) | Km: #{l.kilometros} | " <>
          "Servicios: $#{redondear(l.valor_servicios)} | " <>
          "Bonificaciones: $#{redondear(l.bonificaciones)} | " <>
          "Alquiler: $#{redondear(l.alquiler)} | " <>
          "Neto: $#{redondear(l.neto)}"
      )

      posicion + 1
    end)
  end

  # --------------------------------------------------
  # R5 — Repartidor con más km cada día
  # --------------------------------------------------

  @doc """
  Muestra el repartidor que recorrió más kilómetros cada día.
  En caso de empate, muestra todos los empatados.
  Al final muestra quién ocupó el primer lugar en más días.

  Recibe:
    - servicios_validos: lista de servicios válidos
    - repartidores: lista de repartidores
  """
  def r5(servicios_validos, repartidores) do
    mostrar("\n=== R5: Repartidor con más km por día ===")

    # Paso 1: días que tienen al menos un servicio válido
    dias_con_servicios =
      Enum.filter(1..6, fn dia ->
        Enum.filter(servicios_validos, fn s -> s.dia == dia end) != []
      end)

    # Paso 2 y 3: para cada día suma los km de cada repartidor
    # y encuentra el máximo y los empatados
    ganadores_por_dia =
      for dia <- dias_con_servicios do
        servicios_dia = Enum.filter(servicios_validos, fn s -> s.dia == dia end)

        km_por_repartidor =
          Enum.map(repartidores, fn r ->
            km =
              servicios_dia
              |> Enum.filter(fn s -> s.repartidor == r.codigo end)
              |> Enum.map(& &1.kilometros)
              |> Enum.sum()

            {r.codigo, km}
          end)

        # El primero de la lista ordenada de mayor a menor tiene el máximo
        [{_codigo, maximo} | _resto] =
          Util2.ordenar(km_por_repartidor, :desc, fn {_c, km} -> km end)

        # Todos los que igualan el máximo (empates)
        ganadores = for {codigo, km} <- km_por_repartidor, km == maximo, do: codigo

        {dia, maximo, ganadores}
      end

    # Paso 4: imprime ganadores de cada día
    Enum.each(ganadores_por_dia, fn {dia, maximo, ganadores} ->
      nombres = Enum.map(ganadores, fn codigo -> nombre_de(codigo, repartidores) end)
      mostrar("Día #{dia}: #{Enum.join(nombres, ", ")} con #{maximo} km")
    end)

    # Paso 5: cuenta en cuántos días fue primero cada repartidor
    if ganadores_por_dia == [] do
      mostrar("No hubo servicios válidos.")
    else
      victorias =
        Enum.map(repartidores, fn r ->
          dias = length(Enum.filter(ganadores_por_dia, fn {_d, _m, g} -> r.codigo in g end))
          {r.codigo, dias}
        end)

      [{_codigo, mas_dias} | _resto] = Util2.ordenar(victorias, :desc, fn {_c, dias} -> dias end)

      primeros = for {codigo, dias} <- victorias, dias == mas_dias, do: codigo
      nombres = Enum.map(primeros, fn codigo -> nombre_de(codigo, repartidores) end)

      mostrar("Primer lugar en más días: #{Enum.join(nombres, ", ")} (#{mas_dias} días)")
    end
  end

  # --------------------------------------------------
  # R6 — Mejor puntualidad ponderada
  # --------------------------------------------------

  @doc """
  Muestra el repartidor con mejor puntualidad entre quienes tengan
  al menos 3 servicios válidos.

  La puntualidad se mide con el retraso promedio PONDERADO por kilómetros:
    suma(retraso * km) / suma(km)

  El MENOR valor ponderado es el mejor (puede ser negativo = entrega anticipada).

  Recibe:
    - servicios_validos: lista de servicios válidos
    - repartidores: lista de repartidores
  """
  def r6(servicios_validos, repartidores) do
    mostrar("\n=== R6: Mejor puntualidad ponderada ===")

    # Paso 1: servicios de cada repartidor
    # Paso 2: se quedan solo los que tienen al menos 3
    # Paso 3: se calcula el retraso ponderado de cada uno
    candidatos =
      repartidores
      |> Enum.map(fn r ->
        {r.codigo, Enum.filter(servicios_validos, fn s -> s.repartidor == r.codigo end)}
      end)
      |> Enum.filter(fn {_codigo, servicios} -> length(servicios) >= 3 end)
      |> Enum.map(fn {codigo, servicios} ->
        suma_ponderada = servicios |> Enum.map(fn s -> s.retraso * s.kilometros end) |> Enum.sum()
        suma_km = servicios |> Enum.map(& &1.kilometros) |> Enum.sum()
        {codigo, suma_ponderada / suma_km, length(servicios)}
      end)

    # Paso 4 y 5: el menor retraso ponderado es el primero al ordenar de menor a mayor
    if candidatos == [] do
      mostrar("Ningún repartidor tiene al menos 3 servicios válidos.")
    else
      [{codigo, ponderado, cantidad} | _resto] =
        Util2.ordenar(candidatos, :asc, fn {_c, p, _n} -> p end)

      mostrar(
        "Mejor puntualidad: #{nombre_de(codigo, repartidores)} (#{codigo}) | " <>
          "Retraso ponderado: #{Float.round(ponderado, 2)} min | " <>
          "Servicios: #{cantidad}"
      )
    end
  end

  # --------------------------------------------------
  # R7 — Total pagado y costo por km
  # --------------------------------------------------

  @doc """
  Muestra el total pagado a todos los repartidores durante la semana
  y el costo promedio por kilómetro.

  Fórmula:
    total_pagado = suma de todos los netos de la liquidación
    km_totales   = suma de todos los kilómetros de la liquidación
    costo_por_km = total_pagado / km_totales

  Recibe:
    - liquidaciones: lista de mapas de liquidación
  """
  def r7(liquidaciones) do
    mostrar("\n=== R7: Total pagado y costo por km ===")

    # Paso 1: suma todos los netos
    total_pagado = Enum.sum(Enum.map(liquidaciones, & &1.neto))
    # Paso 2: suma todos los kilómetros
    km_totales = Enum.sum(Enum.map(liquidaciones, & &1.kilometros))

    mostrar("Total pagado: $#{redondear(total_pagado)}")
    mostrar("Kilómetros totales: #{km_totales}")

    # Paso 3: calcula y muestra el costo por km (evita dividir entre cero)
    if km_totales > 0 do
      mostrar("Costo promedio por km: $#{redondear(total_pagado / km_totales)}")
    else
      mostrar("Costo promedio por km: no se puede calcular (0 km)")
    end
  end

  # --------------------------------------------------
  # R8 — Repartidores en todas las zonas
  # --------------------------------------------------

  @doc """
  Muestra los repartidores que realizaron al menos un servicio válido
  en TODAS las zonas.

  Recibe:
    - servicios_validos: lista de servicios válidos
    - repartidores: lista de repartidores
    - zonas: lista de zonas
  """
  def r8(servicios_validos, repartidores, zonas) do
    mostrar("\n=== R8: Repartidores en todas las zonas ===")

    # Un repartidor cumple si NO le queda ninguna zona sin servicios válidos
    cumplen =
      Enum.filter(repartidores, fn r ->
        zonas_sin_servicio =
          Enum.filter(zonas, fn zona ->
            servicios_en_zona =
              Enum.filter(servicios_validos, fn s ->
                s.repartidor == r.codigo and s.zona == zona.id
              end)

            servicios_en_zona == []
          end)

        zonas_sin_servicio == []
      end)

    if cumplen == [] do
      mostrar("Ningún repartidor trabajó en todas las zonas.")
    else
      Enum.each(cumplen, fn r -> mostrar("#{r.nombre} (#{r.codigo})") end)
    end
  end

  # --------------------------------------------------
  # Funciones auxiliares privadas
  # --------------------------------------------------

  # Imprime un mensaje usando el módulo de utilidades del curso.
  defp mostrar(mensaje), do: Util2.mostrar(mensaje, :mensaje)

  # Redondea a 2 decimales. El `* 1.0` evita el error de Float.round con enteros
  # (por ejemplo, el neto de un repartidor sin servicios es el entero 0).
  defp redondear(numero), do: Float.round(numero * 1.0, 2)

  # Busca el nombre de un repartidor por su código.
  defp nombre_de(codigo, repartidores) do
    case Enum.filter(repartidores, fn r -> r.codigo == codigo end) do
      [] -> codigo
      [repartidor | _resto] -> repartidor.nombre
    end
  end
end
 