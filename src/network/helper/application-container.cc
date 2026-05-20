/*
 * Copyright (c) 2008 INRIA
 *
 * SPDX-License-Identifier: GPL-2.0-only
 *
 * Author: Mathieu Lacage <mathieu.lacage@sophia.inria.fr>
 */

#include "application-container.h"

#include "ns3/simulator.h"

#include "ns3/log.h"
#include "ns3/names.h"

namespace ns3
{

NS_LOG_COMPONENT_DEFINE("ApplicationContainer");

ApplicationContainer::ApplicationContainer()
{
}

ApplicationContainer::ApplicationContainer(Ptr<Application> app)
{
    m_applications.push_back(app);
}

ApplicationContainer::ApplicationContainer(std::string name)
{
    Ptr<Application> app = Names::Find<Application>(name);
    m_applications.push_back(app);
}

ApplicationContainer::Iterator
ApplicationContainer::Begin() const
{
    return m_applications.begin();
}

ApplicationContainer::Iterator
ApplicationContainer::End() const
{
    return m_applications.end();
}

uint32_t
ApplicationContainer::GetN() const
{
    return m_applications.size();
}

Ptr<Application>
ApplicationContainer::Get(uint32_t i) const
{
    return m_applications[i];
}

void
ApplicationContainer::Add(ApplicationContainer other)
{
    for (auto i = other.Begin(); i != other.End(); i++)
    {
        if(m_enableReliabilityMode)
        {
            Ptr<Application> app = *i;
            app->EnableReliabilityMode();
        }
        m_applications.push_back(*i);
    }
}

void
ApplicationContainer::Add(Ptr<Application> application)
{
    if(m_enableReliabilityMode)
    {
        application->EnableReliabilityMode();
    }
    m_applications.push_back(application);
}

void
ApplicationContainer::Add(std::string name)
{
    Ptr<Application> application = Names::Find<Application>(name);
    if(m_enableReliabilityMode)
    {
        application->EnableReliabilityMode();
    }
    m_applications.push_back(application);
}

void
ApplicationContainer::Start(Time start) const
{
    NS_LOG_FUNCTION(this);

    Ptr<Application> firstApp = *Begin();

    if(m_enableReliabilityMode && (firstApp->GetInstanceTypeId().GetName() == "ns3::UdpClient"))
    {
        Simulator::Schedule(start, &ApplicationContainer::DesignatePacketToSend, this);
    }

    for (auto i = Begin(); i != End(); ++i)
    {
        Ptr<Application> app = *i;
        app->SetStartTime(start);
    }
}

void
ApplicationContainer::StartWithJitter(Time start, Ptr<RandomVariableStream> rv) const
{
    NS_LOG_FUNCTION(this);

    for (auto i = Begin(); i != End(); ++i)
    {
        Ptr<Application> app = *i;
        double value = rv->GetValue();
        NS_LOG_DEBUG("Start application at time " << start.GetSeconds() + value << "s");
        app->SetStartTime(start + Seconds(value));
    }
}

void
ApplicationContainer::Stop(Time stop) const
{
    NS_LOG_FUNCTION(this);

    for (auto i = Begin(); i != End(); ++i)
    {
        Ptr<Application> app = *i;
        app->SetStopTime(stop);
    }
}

void
ApplicationContainer::DesignatePacketToSend() const
{
    NS_LOG_FUNCTION(this);

    Ptr<Application> firstApp = *Begin();
    auto p = firstApp->GetDesignatedPacket();
    Time packetInterval;
    if (m_enablePoisson)
    {
        Ptr<ExponentialRandomVariable> x = CreateObject<ExponentialRandomVariable> ();
        x->SetAttribute ("Mean", DoubleValue(1/firstApp->GetPoissonLambda()));
        packetInterval = Seconds(x->GetValue());
    }    

    for (auto i = Begin(); i != End(); ++i)
    {
        Ptr<Application> app = *i;
        app->SetDesignatedPacket(p);
        if (m_enablePoisson)
        {
            app->SetInterval(packetInterval);
        }
    }

    Simulator::Schedule(firstApp->GetInterval(), std::bind(&ApplicationContainer::DesignatePacketToSend, this));
}

void 
ApplicationContainer::EnableReliabilityMode()
{
    NS_LOG_FUNCTION(this);
    std::cout << "Enabling reliability mode for all applications in container at time " << Simulator::Now().As(Time::S) << std::endl;
    m_enableReliabilityMode = true;
    for (auto i = Begin(); i != End(); ++i)
    {
        std::cout << "Enabling reliability mode for app " << std::endl;
        Ptr<Application> app = *i;
        app->EnableReliabilityMode();
    }
}

void ApplicationContainer::DisableReliabilityMode()
{
    NS_LOG_FUNCTION(this);
    m_enableReliabilityMode = false;
    for (auto i = Begin(); i != End(); ++i)
    {
        Ptr<Application> app = *i;
        app->DisableReliabilityMode();
    }
}

void ApplicationContainer::DisableReliabilityModePerApp(std::string appId)
{
    NS_LOG_FUNCTION(this << appId);
    uint32_t index = 0;
    for (auto i = Begin(); i != End(); ++i, ++index)
    {
        // Ptr<Application> app = *i;
        // if (true == appId.compare(std::to_string(app->GetInstanceTypeId().GetUid())))
        // {
        //     std::cout << "Disable reliability mode for app " << appId << " at time " << Simulator::Now().As(Time::S) << std::endl;
        //     app->DisableReliabilityMode();
        // }

        if (index >= appId.size())
        {
            break;
        }

        // Check bitmask
        if (appId[index] == '1')
        {
            Ptr<Application> app = *i;
            app->DisableReliabilityMode();
        }
    }
}

void ApplicationContainer::EnableReliabilityModePerApp(std::string appId)
{
    NS_LOG_FUNCTION(this << appId);
    // int8_t count = 0;
    // for (auto i = Begin(); i != End(); ++i)
    // {
    //     Ptr<Application> app = *i;
    //     if (count == std::stoi(appId))
    //     {
    //         std::cout << "Enable reliability mode for app " << appId << " at time " << Simulator::Now().As(Time::S) << std::endl;
    //         app->EnableReliabilityMode();
    //     }
    //     count++;
    // }

    uint32_t index = 0;
    for (auto i = Begin(); i != End(); ++i, ++index)
    {
        // Ptr<Application> app = *i;
        // if (true == appId.compare(std::to_string(app->GetInstanceTypeId().GetUid())))
        // {
        //     std::cout << "Disable reliability mode for app " << appId << " at time " << Simulator::Now().As(Time::S) << std::endl;
        //     app->DisableReliabilityMode();
        // }

         if (index >= appId.size())
        {
            break;
        }

        // Check bitmask
        if (appId[index] == '1')
        {
            Ptr<Application> app = *i;
            app->EnableReliabilityMode();
        }
    }
}

void 
ApplicationContainer::EnablePoissonTraffic()
{
    NS_LOG_FUNCTION(this);
    m_enablePoisson = true;
}

} // namespace ns3
