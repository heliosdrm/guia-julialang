function amanecer_anochecer(d, m, y, long, lat, evento, criterio="normal")
	# Coseno del cénit según el criterio escogido
	cz = Dict("normal" => -0.01454,
		"civil" => -0.10453,
		"nautico" => -0.20791,
		"astronomico" => -0.30902)[criterio]
	# Formulas
	mean_anomaly = t -> 0.9856t - 3.289                             # (1)
	true_longitude = M -> M + 1.916sind(M) + .02sind(2M) + 282.634  # (2)
	right_ascension = L -> atand(0.91746tand(L))                    # (3)
	sin_decl = L -> 0.39782sind(L)                                  # (4)
	cH = (cz, sδ, cδ, sφ, cφ) -> (cz-sδ*sφ)/(cδ*cφ)                 # (5)
	local_time = (H,RA) -> H + RA - 0.065710t - 6.622               # (6)
	universal_time = (t, λ) -> t - λ                                # (7)
	# Paso 0. Calcular t:
	# tiempo aproximado del fenómeno en días desde el comienzo del año
	# El día desde el comienzo del año se calcula según la pág. B1 del
	# Almanac for Computers (1990)
	N = floor(275m/9) - floor((m+9)/12)*(1+floor((mod(y,4)+2)/3)) + d - 30
	# A N se le añaden 6 horas para el amanecer, y 18 para el anochecer,
	# menos la longitud del lugar objetivo expresada en horas
	# (λ = long (grados) *24 (horas) /360 (grados) = long/15)
	λ = long/15
	t_aprox = Dict("amanecer"=>6.0, "anochecer"=>18.0)[evento]
	t = N + (t_aprox-λ)/24
	# Paso 1. A partir del tiempo t: usar (1) y (2) para calcular
	# la anomalía media (M) y la longitud verdadera del Sol (L)
	M = mean_anomaly(t)
	L = true_longitude(M)
	# Paso 2. Calcular la ascensión recta (RA) en t a partir de (3).
	# Ajustando el resultado para que esté en el mismo cuadrante que L
	# (como atand da el resultado en ±π/2, cambiarlo si cosd(L) < 0)
	RA = right_ascension(L)
	if cosd(L) < 0
		RA += 180
	end
	# Transformar RA en horas para usarlo en (6)
	RA /= 15
	# Paso 3. Calcular el seno de la declinación solar en t (sδ) a través de (4),
	# y el coseno correspondiente (cδ, con valor positivo) para usarlos en (5)
	sδ = sin_decl(L)
	cδ = sqrt(1 - sδ^2)
	# Paso 4. Calcular el coseno del ángulo horario del Sol (cH) a partir de (5),
	# usando el coseno del cénit (cz) y el seno y coseno de la latitud (cφ, sφ).
	x = cH(cz, sδ, cδ, sind(lat), cosd(lat))
	# No considerar casos en que |x| > 1
	# (no hay amanecer o anochecer en esa latitud para ese día)
	if abs(x) > 1
		error("No hay amanecer o anochecer en el día y lugar especificados")
	end
	# Calcular el ángulo horario H como positivo o negativo según si se
	# considera el amanecer o el anochecer, y expresar en horas:
	H = Dict(
		"amanecer" => (360.0 - acosd(x))/15.0,
		"anochecer" => acosd(x)/15.0
		)[evento]
	# Paso 5. Calcular la hora local exacta del amanecer y el anochecer (T)
	# a partir de (6), convertida al rango (0-24h)
	T = mod(local_time(H, RA), 24)
	# Paso 6. Convertir a hora universal (desde el meridiano de Greenwich)
	# usando la ecuación (7)
	UT = mod(universal_time(T, λ), 24)
end

