import click
import tomli
import psycopg2 as pg


@click.command()
@click.argument("query", type=click.Path(exists=True))
@click.argument("output", default="output.csv")
def eda(query, output):
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
    write_csv(output, cur.fetchall())
    # close connection
    conn.close()


def read_config(fp):
    with open(fp, "rb") as f:
        return tomli.load(f)


def read_query(fp):
    with open(fp, "r") as f:
        return f.read()


def write_csv(fp, data):
    with open(fp, "w") as f:
        for row in data:
            f.write(",".join(map(str, row)) + "\n")


if __name__ == "__main__":
    eda()
