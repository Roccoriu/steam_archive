from datetime import date

from sqlalchemy.orm import DeclarativeBase, Mapped, mapped_column


class Base(DeclarativeBase):
    """ "
    Base class for all models. It inherits from SQLAlchemy's DeclarativeBase
    """

    pass


class HWSurvey(Base):
    __tablename__ = "hw_survey"

    id: Mapped[int] = mapped_column(primary_key=True)
    date: Mapped[date]
