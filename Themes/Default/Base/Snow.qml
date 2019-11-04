import QtQuick 2.5
import QtQuick.Particles 2.0

Item
{
    id: root
    x: 0; y: 0
    width: parent.width; height: parent.height

    ParticleSystem
    {
        id: particleSystem
    }

    Emitter
    {
        system: particleSystem
                emitRate: 30
                lifeSpan: 20000
                velocity: PointDirection { y:0; yVariation: 40; }
                acceleration: PointDirection { y: 8 }
                size: 10
                endSize: 10
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
        pace: 250;
    }

    ImageParticle
    {
        source: mythUtils.findThemeFile("images/snowflake.png")
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
