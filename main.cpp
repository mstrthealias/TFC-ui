#include <QApplication>
#include <QQmlApplicationEngine>
#include <QDebug>

#include "back_end.h"
#include "log_list_model.h"


int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

    QApplication app(argc, argv);

    qmlRegisterType<LogListModel>("LogListModel", 0, 1, "LogListModel");
    qmlRegisterType<BackEnd>("BackEnd", 1, 0, "BackEnd");

    QQmlApplicationEngine engine;
    const QUrl url(QStringLiteral("qrc:/main.qml"));
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);

    engine.load(url);

    BackEnd *backEnd = engine.rootObjects().first()->findChild<BackEnd*>(QStringLiteral("backEnd"));
    if (backEnd) {
        qDebug() << "backEnd:" << backEnd;
    }

    //QObject::connect(engine.rootObjects().first()->findChild<QObject*>(QStringLiteral("backEnd")), SIGNAL(closeDevTools()), utils, SLOT(onCloseDevTools()));

    return app.exec();
}


//#include "main.moc"
