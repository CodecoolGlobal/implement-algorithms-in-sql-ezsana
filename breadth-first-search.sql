-- SQL statements that are used to define the breadth-first search function
-- Include all your tried solutions in the SQL file
-- with commenting below the functions the execution times on the tested dictionaries.

/*
 See the png file graph-full.png. This graph is directed but treat it as undirected (from-to order of nodes on edges
 doesn't matter) in your function. Edge notes describes the nature of the friendship: p means pending, a means approved,
 h means hidden, r means rejected.
 Create a PL/pgSQL function that can do breadth-first traversal from a given person. The function should return the
 accumulated number of confirmed friends of the given person.
 Confirmed friends = approved edges here.
 */

CREATE OR REPLACE FUNCTION check_pair(id1 int, id2 int) RETURNS boolean AS $$
    DECLARE
        sum_of_hits int DEFAULT 0;
    BEGIN
        SELECT count(*) INTO sum_of_hits FROM (
            SELECT * FROM friends_edges WHERE edge_point_1 = id1 AND edge_point_2 = id2
            UNION ALL
            SELECT * FROM friends_edges WHERE edge_point_1 = id2 AND edge_point_2 = id1
            ) AS pairs;
        RETURN sum_of_hits = 0;
    END;$$
    LANGUAGE plpgsql;

CREATE TEMPORARY TABLE friends_nodes (
    id int PRIMARY KEY,
    name varchar(255)
);

CREATE TEMPORARY TABLE friends_edges (
    edge_point_1 int NOT NULL REFERENCES friends_nodes(id) ON UPDATE CASCADE ON DELETE CASCADE,
    edge_point_2 int NOT NULL REFERENCES friends_nodes(id) ON UPDATE CASCADE ON DELETE CASCADE,
    PRIMARY KEY (edge_point_1, edge_point_2),
    CHECK ( check_pair(edge_point_1, edge_point_2) )
);

CREATE INDEX ep1_index ON friends_edges(edge_point_1);
CREATE INDEX ep2_index ON friends_edges(edge_point_2);

CREATE OR REPLACE FUNCTION insert_values_to_friends_nodes()
AS $$
    DECLARE
        names varchar(255) := '{"one", "two", "three", "four", "five", "six", "seven", "eight", "nine", "ten", "eleven",' ||
                                  '"twelve", "thirteen", "fourteen", "fifteen"}';
    BEGIN
        for i in 1..15 loop
            INSERT INTO friends_nodes VALUES (i, names[i]);
        end loop;
    end;$$
    LANGUAGE plpgsql;

/*
 Adjacency list of the graph:
 1 -> 2 - 4 - 6 - 10;
 2 -> 1 - 8 - 11;
 3 -> 7 - 10;
 4 -> 1;
 5 -> 6;
 6 -> 1 - 5 - 8;
 7 -> 3;
 8 -> 2 - 6 - 9;
 9 -> 8 - 11 - 15;
 10 -> 1 - 3 - 11;
 11 -> 2 - 9 - 10;
 12 -> 13 - 14;
 13 -> 12 - 14;
 14 -> 12 - 13;
 15 -> 9;
 */

CREATE OR REPLACE FUNCTION insert_values_to_friends_edges()
AS $$
    DECLARE
        edge_node_pairs int[][] := '{{1,2}, {1,4}, {1,6}, {1,10}, {2,8}, {2,11}, {3,7}, {3,10}, {5,6}, {6,8},' ||
                                   ' {8,9}, {9,11}, {9,15}, {10,11}, {12,13}, {12,14}, {13,14}}';
        node_pairs int[];
    BEGIN
        foreach node_pairs slice 1 in ARRAY edge_node_pairs
        loop
            INSERT INTO friends_edges VALUES (node_pairs[1], node_pairs[2]);
        end loop;
    END;$$
    LANGUAGE plpgsql;

SELECT insert_values_to_friends_nodes();
SELECT insert_values_to_friends_edges();

-- Function to find out the connections:

CREATE OR REPLACE FUNCTION get_connections(searched_id int) RETURNS table(vertice int) AS $$
DECLARE
    ids record;
BEGIN
    for ids in
        SELECT * FROM friends_edges WHERE edge_point_2 = searched_id OR edge_point_1 = searched_id loop
        if ids.edge_point_2 = searched_id then
            SELECT ids.edge_point_1, ids.edge_point_2 into ids.edge_point_2, ids.edge_point_1;
        end if;
        vertice := ids.edge_point_2;
        RETURN next;
    end loop;
end;$$
LANGUAGE plpgsql;