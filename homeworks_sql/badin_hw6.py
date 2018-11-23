import os
import logging

import psycopg2
import psycopg2.extensions
from pymongo import MongoClient
import pandas as pd
from sqlalchemy import create_engine
from sqlalchemy import and_
from sqlalchemy import Table, Column, Integer, Float, MetaData, String
from sqlalchemy.orm import sessionmaker
from sqlalchemy.ext.declarative import declarative_base


logging.basicConfig(format='%(asctime)s : %(levelname)s : %(message)s', level=logging.INFO)
logger = logging.getLogger(__name__)

# Задание по Psycopg2
# --------------------------------------------------------------

logger.info("Создаём подключёние к Postgres")
params = {
    "host": os.environ['APP_POSTGRES_HOST'],
    "port": os.environ['APP_POSTGRES_PORT'],
    "user": 'postgres'
}
conn = psycopg2.connect(**params)

# дополнительные настройки
psycopg2.extensions.register_type(
    psycopg2.extensions.UNICODE,
    conn
)
conn.set_isolation_level(
    psycopg2.extensions.ISOLATION_LEVEL_AUTOCOMMIT
)
cursor = conn.cursor()

# ВАШ КОД ЗДЕСЬ
# -------------
# таблица movies_top
# movieId (id фильма), ratings_num(число рейтингов), ratings_avg (средний рейтинг фильма)

sql_str = '''
select * into movies_top from (
    select movieid,
           count(rating) as ratings_num,
           avg(rating) as ratings_avg
    from ratings group by movieid) as movies_top_tmp;
'''

# -------------

cursor.execute(sql_str)
conn.commit()

# Проверка - выгружаем данные
cursor.execute("SELECT * FROM movies_top LIMIT 10")
logger.info(
    "Выгружаем данные из таблицы movies_top: (movieId, ratings_num, ratings_avg)\n{}".format(
        [i for i in cursor.fetchall()])
)


# Задание по SQLAlchemy
# --------------------------------------------------------------
Base = declarative_base()


class MoviesTop(Base):
    __tablename__ = 'movies_top'

    movieid = Column(Integer, primary_key=True)
    ratings_num = Column(Float)
    ratings_avg = Column(Float)

    def __repr__(self):
        return "<User(movieid='%s', ratings_num='%s', ratings_avg='%s')>" % (self.movieid, self.ratings_num, self.ratings_avg)


# Создаём сессию

engine = create_engine('postgresql://postgres:@{}:{}'.format(os.environ['APP_POSTGRES_HOST'], os.environ['APP_POSTGRES_PORT']))
Session = sessionmaker(bind=engine)
session = Session()


# --------------------------------------------------------------
# Ваш код здесь
# выберите контент у которого больше 15 оценок (используйте filter)
# и средний рейтинг больше 3.5 (filter ещё раз)
# отсортированный по среднему рейтингу (используйте order_by())
# id такого контента нужно сохранить в массив top_rated_content_ids

content_movie_query = session.query(MoviesTop).filter(
    and_(MoviesTop.ratings_num > 15, MoviesTop.ratings_avg > 3.5)
).order_by(MoviesTop.ratings_avg.desc())

top_rated_query = content_movie_query

top_rated_content_ids = [
    i[0] for i in top_rated_query.values(MoviesTop.movieid)
]

# --------------------------------------------------------------

# Задание по PyMongo
mongo = MongoClient(**{
    'host': os.environ['APP_MONGO_HOST'],
    'port': int(os.environ['APP_MONGO_PORT'])
})

# Получите доступ к коллекции tags
db = mongo["movie"]
tags_collection = db['tags']

# id контента используйте для фильтрации - передайте его в модификатор $in внутри find
# в выборку должны попать теги фильмов из массива top_rated_content_ids
mongo_query = tags_collection.find(
        {'id': {'$in' : top_rated_content_ids}}
)
mongo_docs = [
    i for i in mongo_query
]

print("Достали документы из Mongo: {}".format(mongo_docs[:5]))

id_tags = [(i['id'], i['name']) for i in mongo_docs]


# Задание по Pandas
# --------------------------------------------------------------
# Постройте таблицу их тегов и определите top-5 самых популярных

# формируем DataFrame
tags_df = pd.DataFrame(id_tags, columns=['movieid', 'tags'])

# --------------------------------------------------------------
# Ваш код здесь
# сгруппируйте по названию тега с помощью group_by
# для каждого тега вычислите, в каком количестве фильмов он встречается
# оставьте top-5 самых популярных тегов
tags_df = tags_df.groupby(by=['tags'])['movieid'].count().sort_values(ascending=False)

top_5_tags = tags_df.head(5)

print(top_5_tags)

logger.info("Домашка выполнена!")
# --------------------------------------------------------------
