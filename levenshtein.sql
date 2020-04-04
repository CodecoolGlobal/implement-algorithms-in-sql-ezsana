-- SQL statements that are used to define the Levenshtein distance function
-- Include all your tried solutions in the SQL file
-- with commenting below the functions the execution times on the tested dictionaries.

CREATE OR REPLACE FUNCTION levenshtein(s1 varchar, s2 varchar) RETURNS integer AS $$
    DECLARE
        value1 integer;
        value2 integer;
        s1_arr varchar[] := string_to_array(s1, null);
        s2_arr varchar[] := string_to_array(s2, null);
        letters varchar[] := '{a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z}';
        letter text;
        lev_number integer := 0;
        plusCounter integer := 0;
        minusCounter integer := 0;
        s3_arr varchar;
    BEGIN
        CREATE TABLE abc (id text);

        foreach letter in array letters loop
            EXECUTE format('ALTER TABLE abc ADD COLUMN %I integer;', letter);
        end loop;

        INSERT INTO abc(id) VALUES ('one');

        foreach letter in array letters loop
            EXECUTE format('UPDATE abc SET %I = $1 WHERE id = $2', letter) USING countLetter(s1_arr, letter), 'one';
        end loop;

        INSERT INTO abc(id) VALUES ('two');

        foreach letter in array letters loop
            EXECUTE format('UPDATE abc SET %I = $1 WHERE id = $2', letter) USING countLetter(s2_arr, letter), 'two';
        end loop;

        foreach letter in array letters loop
            EXECUTE format('SELECT %I FROM abc WHERE id = $1;', letter) INTO value1 USING 'one';
            EXECUTE format('SELECT %I FROM abc WHERE id = $1;', letter) INTO value2 USING 'two';
            if (value2 - value1) < 0 then
                minusCounter = minusCounter - (value2 - value1);
            elsif (value2 - value1) > 0 then
                plusCounter = plusCounter + (value2 - value1);
            end if;
        end loop;
        if (minusCounter = plusCounter) then
            lev_number = plusCounter;
        elsif (abs(minusCounter) > abs(plusCounter)) then
            lev_number = abs(minusCounter);
        elsif (abs(plusCounter) > abs(minusCounter)) then
            lev_number = abs(plusCounter);
        end if;

        DROP TABLE abc;
        RETURN lev_number;
    END;
    $$
    LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION countLetter(s varchar[], l varchar(1)) RETURNS integer AS $$
    DECLARE
        count integer := 0;
        letter varchar(1);
    BEGIN
        foreach letter in array s loop
            if l = letter then
                count = count + 1;
            end if;
            end loop;
    RETURN count;
    end;
    $$
    LANGUAGE plpgsql;




