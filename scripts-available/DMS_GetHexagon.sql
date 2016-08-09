CREATE OR REPLACE FUNCTION DMS_GetHexagon(point GEOMETRY, side FLOAT) RETURNS GEOMETRY as $$
DECLARE
x FLOAT;
y FLOAT;
b bool;
co INTEGER;
ro INTEGER;
relY FLOAT;
relX FLOAT;
m FLOAT;
ch FLOAT;
ghh FLOAT;
res GEOMETRY;
hex GEOMETRY[];
d FLOAT;
h FLOAT;
SRID INTEGER;
BEGIN
	x := ST_X(point);
	y := ST_Y(point);
	d := side * 2;
	h := sqrt(3) * side;
	ch := side / 2;
	ghh := side * 1.5;
	m := ( h / 2 ) / ch;

	co := floor(x / ghh);
	b := abs(co % 2) = 1;

	SRID := ST_SRID(point);
	hex := array_append(hex, ST_SetSRID(CDB_MakeHexagon(ST_MakePoint( side, (h / 2)), side), SRID));
	hex := array_append(hex, ST_SetSRID(CDB_MakeHexagon(ST_MakePoint( side, 0), side), SRID));

	IF b THEN
		ro := floor(((y + ( h / 2 )) / h));
		RAISE NOTICE 'y: % y - ( h / 2 ): % ro*h: % ((y - ( h / 2 )) / h): %', y, (y - ( h / 2 )), (ro*h), ((y - ( h / 2 )) / h);
	ELSE
		ro := floor(y / h);
		RAISE NOTICE 'y: % ro*h: %', y, (ro*h);
	END IF;

	relX := x - (co * ghh);


	IF b THEN
		relY := y - (ro * h);
	ELSE
		relY := (y - ro * h) - ( h / 2 );
	END IF;
	RAISE NOTICE 'co %, ro %', co, ro;
	IF relY > (m * relX) THEN
		RAISE NOTICE 'relY > (m * relX)  % > %', relY, (m * relX);
		co := co-1;
		IF NOT b THEN
			ro := ro+1;
		END IF;
	ELSIF relY < (-m * relX) THEN
		RAISE NOTICE 'relY < (-m * relX)  % < %', relY, (-m * relX);
		co := co-1;
		IF b THEN
			ro := ro-1;
		END IF;
	END IF;
	RAISE NOTICE 'co %, ro %', co, ro;
	res := ST_Translate(hex[abs(co % 2) +1], co *side * 1.5, ro * h );

	RETURN res;
END;
$$ LANGUAGE 'plpgsql' IMMUTABLE;
