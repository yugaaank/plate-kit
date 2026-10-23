// plate-kit Qt port — app entry.
//
// Plain Qt, no Quickshell. This file is deliberately tiny: everything App-level
// lives in QML (app/main.qml), and everything shell-specific the kit lost in the
// port is replaced right here:
//
//   * Quickshell synthesized its root module from uppercase root files; a Qt
//     app embeds the kit as a registered QML module instead (engine.addImportPath
//     over the compiled-in qrc/platekit/qmldir makes `import PlateKit` work).
//   * Quick Controls style is pinned to Basic, same as the Quickshell kit pins
//     it — otherwise the desktop style (Plasma's) silently re-themes the few
//     Controls the kit does not fully own.
//   * The wallpaper-derived palette (colors.json, matugen output) is read here
//     and injected as the `PlateThemeJson` context property; the QML side maps
//     it onto Appearance's m3colors (platekit/PlateThemeLoader.qml).
#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>

#include <QQuickStyle>
#include <QFile>
#include <QJsonDocument>
#include <QJsonObject>
#include <QStandardPaths>
#include <QDir>
#include <QCoreApplication>
#include <cstdio>
#include <QFile>
static FILE *g_log = nullptr;
static void slog(const char *msg) { if (!g_log) g_log = fopen("/tmp/opencode/plateapp-debug.log", "a"); if (g_log) { fprintf(g_log, "%s\n", msg); fflush(g_log); } }

int main(int argc, char *argv[])
{
    QQuickStyle::setStyle(QStringLiteral("Basic"));

    QGuiApplication app(argc, argv);
    QGuiApplication::setApplicationName(QStringLiteral("plate-app"));

    QQmlApplicationEngine engine;

    // Same file the Quickshell kit's MaterialThemeLoader watches:
    // ~/.local/state/user/generated/colors.json (matugen's output).
    QVariantMap theme;
    const QString themePath = QStandardPaths::writableLocation(QStandardPaths::HomeLocation)
        + QStringLiteral("/.local/state/user/generated/colors.json");
    QFile themeFile(themePath);
    if (themeFile.open(QIODevice::ReadOnly)) {
        const QJsonDocument doc = QJsonDocument::fromJson(themeFile.readAll());
        themeFile.close();
        if (!doc.isNull() && doc.isObject())
            theme = doc.object().toVariantMap();
    } else {
        qWarning() << "[plate-app] no colors.json at" << themePath << "- using Appearance's built-in palette.";
    }
    engine.rootContext()->setContextProperty(QStringLiteral("PlateThemeJson"), theme);

    // Register the kit module from the kit's own tree (dev mode).
    // The module lives in the sibling ./PlateKit directory (dir name MUST equal the
    // module name — "module PlateKit is not installed" otherwise). main.qml below is
    // likewise loaded from ./app, so QML edits need no rebuild. qrc embeds only the
    // fonts (qrc:/PlateKit/fonts). For a self-contained shipping binary, CMake's
    // qt_add_qml_module registers the module from compiled resources instead.
    engine.addImportPath(QCoreApplication::applicationDirPath());

    QObject::connect(&engine, &QQmlApplicationEngine::objectCreationFailed, &app, []() {
        qWarning() << "[plate-app] main.qml FAILED";
        QCoreApplication::exit(1);
    }, Qt::QueuedConnection);


    // --- diagnostics ---
    {
    }
    // --- end diagnostics ---
    engine.load(QUrl::fromLocalFile(QCoreApplication::applicationDirPath() + QStringLiteral("/app/main.qml")));

    return app.exec();
}
