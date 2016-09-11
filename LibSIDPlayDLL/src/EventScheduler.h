/*
 * This file is part of libsidplayfp, a SID player engine.
 *
 *  Copyright (C) 2011-2012 Leandro Nini
 *  Copyright (C) 2009 Antti S. Lankila
 *  Copyright (C) 2001 Simon White
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, write to the Free Software
 *  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
 */

#ifndef EVENTSCHEDULER_H
#define EVENTSCHEDULER_H

#include "event.h"


template< class This >
class EventCallback: public Event
{
private:
    typedef void (This::*Callback) ();

private:
    This &m_this;
    Callback const m_callback;

private:
    void event() { (m_this.*m_callback)(); }

public:
    EventCallback(const char * const name, This &_this, Callback callback) :
        Event(name),
        m_this(_this),
        m_callback(callback) {}
};


/**
 * Fast EventScheduler implementation
 *
 * @author Antti S. Lankila
 */
class EventScheduler: public EventContext
{
private:
    /// EventScheduler's current clock.
    event_clock_t  currentTime;

    /// The first event of the chain.
    Event *firstEvent;

private:
    /**
     * Scan the event queue and schedule event for execution.
     *
     * @param event The event to add
     */
    void schedule(Event &event)
    {
        // find the right spot where to tuck this new event
        Event **scan = &firstEvent;
        for (;;)
        {
            if (*scan == 0 || (*scan)->triggerTime > event.triggerTime)
            {
                 event.next = *scan;
                 *scan = &event;
                 break;
             }
             scan = &((*scan)->next);
         }
    }

protected:
    void schedule(Event &event, unsigned int cycles,
                   event_phase_t phase)
    {
        // this strange formulation always selects the next available slot regardless of specified phase.
        event.triggerTime = currentTime + ((currentTime & 1) ^ phase) + (cycles << 1);
        schedule(event);
    }

    void schedule(Event &event, unsigned int cycles)
    {
        event.triggerTime = currentTime + (cycles << 1);
        schedule(event);
    }

    void cancel(Event &event);

public:
    EventScheduler () :
          currentTime(0),
          firstEvent(0) {}

    /**
     * Cancel all pending events and reset time.
     */
    void reset();

    /**
     * Fire next event, advance system time to that event.
     */
    void clock()
    {
        Event &event = *firstEvent;
        firstEvent = firstEvent->next;
        currentTime = event.triggerTime;
        event.event();
    }

    /**
     * Check if an event is in the queue.
     */
    bool isPending(Event &event) const;

    event_clock_t getTime(event_phase_t phase) const
    {
        return (currentTime + (phase ^ 1)) >> 1;
    }

    event_clock_t getTime(event_clock_t clock, event_phase_t phase) const
    {
        return getTime (phase) - clock;
    }

    event_phase_t phase() const { return (event_phase_t) (currentTime & 1); }
};

#endif // EVENTSCHEDULER_H
