import QtQuick 2.5
import QtQuick.Particles 2.0

Item
{
    id: root

    property alias imageSource: imageParticle.source

    x: 0; y: 0
    width: parent.width; height: parent.height

    ParticleSystem
    {
        id: particleSystem
        running: root.visible
    }

    Emitter
    {
        system: particleSystem
                emitRate: 30
                lifeSpan: 20000
                velocity: PointDirection { y:0; yVariation: 40; }
                acceleration: PointDirection { y: 8 }
                size: xscale(10)
                endSize: xscale(10)
                sizeVariation: 2
                width: parent.width
                height: 1
    }

    Wander
    {
        id: wanderer
        system: particleSystem
        anchors.fill: parent
        xVariance: 25;
        pace: 300;
    }

    ImageParticle
    {
        id: imageParticle
        source: mythUtils.findThemeFile("images/snow.png")
        system: particleSystem
        color: "#ffffff"
        colorVariation: 0.2
        rotation: 0
        rotationVariation: 45
        rotationVelocity: 15
        rotationVelocityVariation: 15
        entryEffect:  ImageParticle.Scale
    }
}
