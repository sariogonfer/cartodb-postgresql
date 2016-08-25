CREATE OR REPLACE FUNCTION DMS_GetHexagonGridFromPointTable(schema_name TEXT, table_name TEXT, column_name TEXT, side FLOAT) RETURNS SETOF GEOMETRY as $$
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
point GEOMETRY;
SRID INTEGER;
BEGIN
	d := side * 2;
	h := sqrt(3) * side;
	ch := side / 2;
	ghh := side * 1.5;
	m := sqrt(3);

	b := abs(co % 2) = 1;

	SRID := Find_SRID(schema_name, table_name, column_name);
	hex := array_append(hex, ST_SetSRID(CDB_MakeHexagon(ST_MakePoint( side, (h / 2)), side), SRID));
	hex := array_append(hex, ST_SetSRID(CDB_MakeHexagon(ST_MakePoint( side, 0), side), SRID));

	FOR point IN EXECUTE 'SELECT ' || column_name || ' FROM ' || table_name LOOP

		x := ST_X(point);
		y := ST_Y(point);

		co := floor(x / ghh);

		IF b THEN
			ro := floor(((y + ( h / 2 )) / h));
			-- RAISE NOTICE 'y: % y + ( h / 2 ): % ro*h: % ((y + ( h / 2 )) / h): %', y, (y + ( h / 2 )), (ro*h), ((y + ( h / 2 )) / h);
		ELSE
			ro := floor(y / h);
			-- RAISE NOTICE 'y: % ro*h: %', y, (ro*h);
		END IF;

		-- RAISE NOTICE 'x: % co * ghh: %', x, co * ghh;
		relX := x - (co * ghh);


		IF b THEN
			relY := y - (ro * h);
		ELSE
			relY := (y - ro * h) - ( h / 2 );
		END IF;
		-- RAISE NOTICE 'co %, ro %', co, ro;
		-- RAISE NOTICE 'relX %, m %', relX, m;
		IF relY > (m * relX) THEN
			-- RAISE NOTICE 'relY > (m * relX)  % > %', relY, (m * relX);
			co := co-1;
			IF NOT b THEN
				ro := ro+1;
			END IF;
		ELSIF relY < (-m * relX) THEN
			-- RAISE NOTICE 'relY < (-m * relX)  % < %', relY, (-m * relX);
			co := co-1;
			IF b THEN
				ro := ro-1;
			END IF;
		END IF;
		-- RAISE NOTICE 'co %, ro %', co, ro;
		res := ST_Translate(hex[abs(co % 2) +1], co*ghh, ro * h );

		RETURN NEXT res;
	END LOOP;
END;
$$ LANGUAGE 'plpgsql' IMMUTABLE;
