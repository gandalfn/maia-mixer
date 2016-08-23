/* glib-2.0.vala
 *
 * Copyright (C) 2009  Alberto Colombo
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301  USA
 *
 * As a special exception, if you use inline functions from this file, this
 * file does not by itself cause the resulting executable to be covered by
 * the GNU Lesser General Public License.
 *
 * Authors:
 * 	Alberto Colombo <albx79@gmail.com>
 *	Raffaele Sandrini <rasa@gmx.ch>
 *	Mathias Hasselmann <mathias.hasselmann@gmx.de>
 *  Harry Van Haaren
 */

// NOTES:
//  1) there are no bindings for deprecated methods;
//  2) this vapi file is to be considered "beta" version, since some bindings may be incorrect;
//     however, correct bindings are not subject to change.

[CCode (lower_case_cprefix = "jack_", cheader_filename="jack/jack.h")]
namespace Jack{

    public const int MAX_FRAMES;
    public const int LOAD_INIT_LIMIT;
    public const string DEFAULT_AUDIO_TYPE;
    public const string DEFAULT_MIDI_TYPE;

    [CCode (cname="JackOpenOptions")]
    public const Options OpenOptions;

    [CCode (cname="JackLoadOptions")]
    public const Options LoadOptions;

    [SimpleType]
    [CCode (cname="jack_shmsize_t")]
    public struct ShmSize : int32 {}

    [SimpleType]
    [IntegerType (rank = 7)]
    [CCode (cname = "jack_nframes_t", cheader_filename = "jack/jack.h",  type_id = "G_TYPE_UINT", marshaller_type_name = "UINT", get_value_function = "g_value_get_uint", set_value_function = "g_value_set_uint", default_value = "0U", type_signature = "u")]
    public struct NFrames : uint32 {}

    [SimpleType]
    [CCode (cname="jack_time_t")]
    public struct Time : uint64 {}

    [SimpleType]
    [CCode (cname="jack_intclient_t", cprefix="jack_internal_client", cheader_filename="jack/intclient.h")]
    public struct InternalClient : uint64
    {
        public static void close(string name);
    }

    [Compact]
    [CCode (cname="jack_port_t", cprefix="jack_port_")]
    public class Port
    {
        [CCode (cprefix="JackPort", cname="enum JackPortFlags", has_type_id=false)]
        [Flags]
        public enum Flags
        {
           IsInput,
           IsOutput,
           IsPhysical,
           CanMonitor,
           IsTerminal
        }

        public static int name_size {
            [CCode (cname = "jack_port_name_size")]
            get;
        }
        public static int type_size {
            [CCode (cname = "jack_port_type_size")]
            get;
        }

        public unowned string name {
            [CCode (cname = "jack_port_name")]
            get;
            [CCode (cname = "jack_port_set_name")]
            set;
        }
        public unowned string short_name {
            [CCode (cname = "jack_port_short_name")]
            get;
        }
        public string owner {
            owned get {
                return name.substring (0, int.max (0, name.length - short_name.length - 1));
            }
        }
        public Flags flags {
            [CCode (cname = "jack_port_flags")]
            get;
        }
        public unowned string type {
            [CCode (cname = "jack_port_type")]
            get;
        }
        public NFrames latency {
            [CCode (cname = "jack_port_get_latency")]
            get;
            [CCode (cname = "jack_port_set_latency")]
            set;
        }
        public NFrames total_latency {
            [CCode (cname = "jack_port_get_total_latency")]
            get;
        }
        public void* get_buffer (NFrames nframes);
        public bool connected ();
        public bool connected_to (string name);
        [CCode (array_null_terminated = true, array_length = false)]
        public string[] get_connections ();
        public int set_alias (string alias);
        public int unset_alias (string alias);
        [CCode (array_length=false)]
        public int get_aliases (out unowned string[] aliases);
        public int request_monitor (bool onoff);
        public int ensure_monitor (bool onoff);
        public int monitoring_input ();
    }

    [Compact]
    [CCode (cname="jack_client_t", free_function="jack_client_close", cprefix="jack_")]
    public class Client
    {
        public static int name_size {
            [CCode (cname="jack_name_size")]
            get;
        }

        public string name {
            [CCode (cname="jack_get_client_name")]
            get;
        }

        public GLib.Thread thread_id {
            [CCode (cname="jack_thread_id")]
            get;
        }

        public int real_time_priority {
            [CCode (cname="jack_real_time_priority")]
            get;
        }
        public int max_real_time_priority {
            [CCode (cname="jack_max_real_time_priority")]
            get;
        }
        public bool is_realtime {
            [CCode (cname="jack_is_realtime")]
            get;
        }

        public NFrames buffer_size {
            [CCode (cname="jack_get_buffer_size")]
            get;
            [CCode (cname="jack_set_buffer_size")]
            set;
        }

        public NFrames sample_rate {
            [CCode (cname = "jack_get_sample_rate")]
            get;
        }

        public float cpu_load {
            [CCode (cname = "jack_cpu_load")]
            get;
        }

        [CCode (cname="jack_client_open")]
        public Client (string name, Jack.Options options, out Jack.Status status, ...);
        public int activate();
        public int deactivate();

        // setting callbacks
        public int set_thread_init_callback(ThreadInitCallback cb);
        public void on_shutdown(ShutdownFunc f);
        public int set_process_callback(ProcessCallback cb);
        public int set_freewheel_callback(FreewheelCallback cb);
        public int set_buffer_size_callback(BufferSizeCallback cb);
        public int set_sample_rate_callback(SampleRateCallback cb);
        public int set_client_registration_callback(ClientRegistrationCallback cb);
        public int set_port_registration_callback(PortRegistrationCallback cb);
        public int set_port_connect_callback(PortConnectCallback cb);
        public int set_graph_order_callback(GraphOrderCallback cb);
        public int set_xrun_callback(XRunCallback cb);

        // controlling and querying server operations
        [CCode (cname="jack_client_create_thread")]
        public int create_thread(out GLib.Thread thread, int priority, bool realtime, ThreadCallback cb);
        public int set_freewheel(bool onoff);

        // creating and manipulating ports
        public unowned Port port_register(string name, string type, Port.Flags flags, ulong buffer_size);
        public int port_unregister(Port p);
        public bool port_is_mine(Port p);
        [CCode (array_null_terminated = true, array_length = false)]
        public string[] port_get_all_connections(Port p);
        public int recompute_total_latency(Port p);
        public int recompute_total_latencies();
        public int port_request_monitor_by_name(string port_name, bool onoff);
        public int connect(string source_port, string destination_port);
        public int disconnect(string source_port, string destination_port);
        public int port_disconnect(Port p);

        // looking up ports
        [CCode (array_null_terminated = true, array_length = false)]
        public unowned string[] get_ports(string? name_pattern, string? type_pattern, Port.Flags flags);
        public unowned Port port_by_name(string name);
        public unowned Port port_by_id(PortId id);

        // handling time
        public NFrames frames_since_cycle_start();
        public NFrames frame_time();
        public NFrames last_frame_time();
        public Time frames_to_time(NFrames nframes);
        public NFrames time_to_frames(Time t);
        public Time get_time();

        // non-callback API
        public NFrames cycle_wait();
        public void cycle_signal(bool should_exit);
        public int set_process_thread(ThreadCallback cb);

        // statistics
        [CCode (cheader_filename="jack/statistics.h")]
        public float get_max_delayed_usecs();
        [CCode (cheader_filename="jack/statistics.h")]
        public float get_xrun_delayed_usecs();
        [CCode (cheader_filename="jack/statistics.h")]
        public void reset_max_delayed_usecs();

        // internal clients
        [CCode (cheader_filename="jack/intclient.h")]
        public string get_internal_client_name(InternalClient intclient);
        [CCode (cheader_filename="jack/intclient.h")]
        public InternalClient internal_client_handle(string name, out Status s);
        public InternalClient internal_client_load(string name, Options opts, out Status s, ...);
        public Status internal_client_unload(InternalClient intclient);

        // transport and timebase control
        public int release_timebase();
        public int set_sync_callback(SyncCallback cb);
        public int set_sync_timeout(Jack.Time timeout);
        public int set_timebase_callback(bool conditional, TimebaseCallback cb);
        public int transport_locate(NFrames frame);
        public TransportState transport_query(out Position pos);
        public NFrames get_current_transport_frame();
        public int transport_reposition(ref Position p);
        public void transport_start();
        public void transport_stop();
    }

    [SimpleType]
    [CCode (cname="jack_port_id_t")]
    public struct PortId : uint32 {}

    public delegate void* ThreadCallback();
    public delegate void ThreadInitCallback();
    public delegate void ShutdownFunc();
    public delegate int ProcessCallback(NFrames nframes);
    public delegate void FreewheelCallback(bool starting);
    public delegate int BufferSizeCallback(NFrames nframes);
    public delegate int SampleRateCallback(NFrames nframes);
    // do not change the parameter name to "register" because it will generate
    // errors at C-compile time
    public delegate void ClientRegistrationCallback(string name, bool reg);
    public delegate void PortRegistrationCallback(PortId id, bool reg);
    public delegate void PortConnectCallback(PortId a, PortId b, bool connect);
    public delegate int GraphOrderCallback();
    public delegate int XRunCallback();

    [SimpleType]
    [CCode (cname="jack_default_audio_sample_t")]
    public struct DefaultAudioSample : float {}

    [CCode (cprefix="Jack", cname="jack_options_t")]
    [Flags]
    public enum Options
    {
        NullOption,
        NoStartServer,
        UseExactName,
        ServerName,
        LoadName,
        LoadInit
    }

    [CCode (cprefix="Jack", cname="jack_status_t")]
    [Flags]
    public enum Status
    {
        Failure,
        InvalidOption,
        NameNotUnique,
        ServerStarted,
        ServerFailed,
        ServerError,
        NoSuchClient,
        LoadFailure,
        InitFailure,
        ShmFailure,
        VersionError
    }

    public int drop_real_time_scheduling (GLib.Thread t);
    public int acquire_real_time_scheduling (GLib.Thread t, int priority);

    // error / information output
    [CCode (has_target = false)]
    public delegate void MessageFunc (string msg);
    void set_error_function (MessageFunc f);
    void set_info_function (MessageFunc f);
    public MessageFunc error_callback;
    public MessageFunc info_callback;
    [CCode (cname="default_jack_error_callback")]
    public void default_error_callback(string msg);
    [CCode (cname="silent_jack_error_callback")]
    public void silent_error_callback(string msg);

    // MIDI
    [CCode (lower_case_cprefix="jack_midi_", cheader_filename="jack/midiport.h")]
    namespace Midi
    {
        [SimpleType]
        [CCode (cname="jack_midi_data_t")]
        public struct Data : uchar {}

        [CCode (cname="jack_midi_event_t", cprefix="jack_midi_event_", destroy_function="")]
        public struct Event
        {
            public NFrames time;
            public size_t size;
            [CCode (array_length = false)]
            public unowned Data[] buffer;
            public static int get(out Event e, void *port_buffer, NFrames event_index);
            [CCode (array_length = false)]
            public static Data* reserve(void *port_buffer, NFrames time, size_t data_size);
            public static int write(void *port_buffer, NFrames time, [CCode (array_length = false)]Data[] data, size_t data_size);
        }
        public NFrames get_event_count(void *port_buffer);
        public void clear_buffer(void *port_buffer);
        public size_t max_event_size(void *port_buffer);
        public NFrames get_lost_event_count(void *port_buffer);
    }

    // ringbuffer
    [Compact]
    [CCode (cheader_filename="jack/ringbuffer.h", cname="jack_ringbuffer_t", cprefix="jack_ringbuffer_", free_function="jack_ringbuffer_free")]
    public class Ringbuffer
    {
        [CCode (cname="jack_ringbuffer_data_t")]
        public struct Data
        {
            public uint8[] buf;
        }

        [CCode (array_length = false)]
        public uint8[] buf;
        public size_t  write_ptr;
        public size_t  read_ptr;
        public size_t  size;
        public size_t  size_mask;
        public bool    mlocked;

        [CCode (cname="jack_ringbuffer_create")]
        public Ringbuffer(size_t sz);

        [CCode (array_length=false)]
        public void get_read_vector(out unowned Data[] vec);
        [CCode (array_length=false)]
        public void get_write_vector(out unowned Data[] vec);
        public size_t read(uint8[] dest);
        public size_t peek(uint8[] dest);
        public void read_advance(size_t cnt);
        public size_t read_space();
        public int mlock();
        public void reset();
        public size_t write(uint8[] src);
        public void write_advance(size_t cnt);
        public size_t write_space();
    }

    // transport and timebase
    public delegate int SyncCallback(TransportState s, Position p);
    public delegate void TimebaseCallback(TransportState s, NFrames nframes, Position p);

    [CCode(cname="jack_transport_state_t", cprefix="JackTransport")]
    public enum TransportState
    {
        Stopped,
        Rolling,
        Looping,
        Starting
    }

    [SimpleType]
    [CCode (cname="jack_unique_t")]
    public struct Unique : uint64 {}

    [CCode (cname="enum jack_position_bits_t", cprefix="Jack")]
    [Flags]
    public enum PositionBits
    {
        PositionBBT,
        PositionTimecode,
        BBTFrameOffset,
        AudioVideoRatio,
        VideoFrameOffset
    }

    [CCode (cname="jack_position_t", free_function="", destroy_function="")]
    public struct Position
    {
        public Unique       unique_1;
        public Jack.Time    usecs;
        public NFrames      frame_rate;
        public NFrames      frame;
        public PositionBits valid;
        public int32        bar;
        public int32        beat;
        public int32        tick;
        public double       bar_start_tick;
        public float        beats_per_bar;
        public float        beat_type;
        public double       ticks_per_beat;
        public double       beats_per_minute;
        public double       frame_time;
        public double       next_time;
        public NFrames      bbt_offset;
        public float        audio_frames_per_video_frame;
        public NFrames      video_offset;
        [CCode (array_length = false)]
        public int32[]      padding;
        public Unique       unique_2;
    }
}
