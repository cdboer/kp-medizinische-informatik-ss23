import click
import tomli
import psycopg2 as pg


@click.command()
@click.argument("query", type=click.Path(exists=True))
@click.argument("output", default="output.csv")
def cli(query, output):
    """Run a SQL query and write the output to a CSV file."""
    # read query
    query = read_query(query)
    # read config
    config = read_config("config.toml")
    # connect to database
    conn = pg.connect(**config["database"])
    # execute query
    cur = conn.cursor()
    cur.execute(query)
    # write csv output to file
    write_csv(output, cur.fetchall(), cur.description)
    # close connection
    conn.close()


def read_config(fp):
    with open(fp, "rb") as f:
        return tomli.load(f)


def read_query(fp):
    with open(fp, "r") as f:
        return f.read()


def write_csv(fp, data, col_names):
    with open(fp, "w") as f:
        f.write(",".join(map(lambda x: x.name, col_names)) + "\n")
        for row in data:
            f.write(",".join(map(str, row)) + "\n")
