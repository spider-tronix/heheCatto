-- This illustrates how to publish and subscribe to an image using the ROS Interface.
-- An alternate version using image transport can be created with following functions:
--
-- simROS.imageTransportAdvertise
-- simROS.imageTransportPublish
-- simROS.imageTransportShutdownPublisher
-- simROS.imageTransportShutdownSubscriber
-- simROS.imageTransportSubscribe

function sysCall_init()
        
    -- Get some handles:
    activeVisionSensor=sim.getObject('.')
    --passiveVisionSensor=sim.getObject('/passiveSensor')

    -- Enable an image publisher and subscriber:
    if simROS then
        sim.addLog(sim.verbosity_scriptinfos,"ROS interface was found.")
        pub=simROS.advertise('/image', 'sensor_msgs/Image')
        simROS.publisherTreatUInt8ArrayAsString(pub) -- treat uint8 arrays as strings (much faster, tables/arrays are kind of slow in Lua)
        --sub=simROS.subscribe('/image', 'sensor_msgs/Image', 'imageMessage_callback')
        --simROS.subscriberTreatUInt8ArrayAsString(sub) -- treat uint8 arrays as strings (much faster, tables/arrays are kind of slow in Lua)
    else
        sim.addLog(sim.verbosity_scripterrors,"ROS interface was not found. Cannot run.")
    end
end

function imageMessage_callback(msg)
    -- Apply the received image to the passive vision sensor that acts as an image container
    --sim.setVisionSensorCharImage(passiveVisionSensor,msg.data)
end


function sysCall_sensing()
    if simROS then   
        -- Publish the image of the active vision sensor:
        local data,w,h=sim.getVisionSensorCharImage(activeVisionSensor)
        d={}
        d.header={stamp=simROS.getTime(), frame_id='a'}
        d.height=h
        d.width=w
        d.encoding='rgb8'
        d.is_bigendian=1
        d.step=w*3
        d.data=data
        simROS.publish(pub,d)
    end
end

function sysCall_cleanup()
    if simROS then   
        -- Shut down publisher and subscriber. Not really needed from a simulation script (automatic shutdown)
        simROS.shutdownPublisher(pub)
        simROS.shutdownSubscriber(sub)
    end
end
