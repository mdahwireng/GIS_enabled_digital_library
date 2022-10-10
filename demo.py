from cProfile import label
import subprocess
import psycopg2


def run_cmd_process(cmd_list) -> tuple:
    """
    Takes a list of elements of a shell command and executes the command
    Returns a tuple of the output, error and return code of the process.

    Args:
        cmd_list(list): list of elements of the shell command

    Returns:
        A tuple of the output, error and return code of the process
    """

    process = subprocess.Popen(cmd_list,
                               stdout=subprocess.PIPE,
                               stderr=subprocess.PIPE,
                               universal_newlines=True)

    # retrieve the output and error
    stdout, stderr = process.communicate()

    return stdout, stderr, process.returncode





# cmd process to convert to generate sql codes to create and staging table for highways and load data into it.
cmd_list = ['shp2pgsql', '-s', '4269:2163', '-g', 'geom', '-I', 'data/roadtrl020.shp', 'case01.highways_staging']

stdout, stderr, r_code = run_cmd_process(cmd_list)

load_shp_query = stdout


# query to load data into highways table
load_to_highways_query = """
INSERT INTO case01.highways (gid, feature, name, state, geom)
SELECT gid, feature, name, state, ST_Transform(geom, 2163)
FROM case01.highways_staging
WHERE feature LIKE 'Principal Highway%';
"""

# Find fastfoods in a mile radius from principal streets
one_mile_query = """
SELECT f.franchaise, COUNT(DISTINCT r.id) AS total
FROM
    case01.restaurants as r 
    INNER JOIN
        case01.franchaises as f 
        ON r.franchaise = f.id
    INNER JOIN
        case01.highways AS h
        ON ST_DWithin(r.geom, h.geom, 1609)
GROUP BY f.franchaise
ORDER BY total DESC;
"""


# Connect to the digital library database
conn = psycopg2.connect(
    database="exampledb",
    user="docker",
    password="docker",
    host="0.0.0.0"
)

# Open cursur to perform database operations
cur = conn.cursor()

# Insert data into highways_staging
cur.execute(load_shp_query)

# Copy and transform data from highway_staging to highways table
cur.execute(load_to_highways_query)

# Query db
cur.execute(one_mile_query)
rows = cur.fetchall()

# Iterate through the returned data from the db
if len(rows) == 0:
    print("Empty Db")
else:
    for row in rows:
        print(row)

# Close the communication lines betwen db and program
cur.close()   # Close cursor
conn.close()  # Close connection