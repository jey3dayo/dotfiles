use Irssi;
use Encode;

our $VERSION = '0.02';
our %IRSSI   = (
    authors     => 'ksk',
    contact     => 'ksk_binzume.net',
    name        => 'conv',
    description => 'convert to utf-8',
    license     => 'NYSL',
    url         => 'http://www.binzume.net/',
    changed     => '2007-10-05',
);

my $local_charset = 'UTF-8';
my $remote_charset = 'UTF-8';

sub send_text {
    my ( $text, $server, $witem ) = @_;

    if ($server && $witem) {
        Encode::from_to($text, $local_charset, $remote_charset );
    }
    Irssi::signal_continue( $text, $server, $witem );
}
Irssi::signal_add( 'send text', 'send_text' );

sub send_command {
        my ($command,$server,$item) = @_;
        Encode::from_to($command, $local_charset, $remote_charset );
        Irssi::signal_continue( $command, $server, $item );
}
Irssi::signal_add( 'send command', 'send_command' );

sub print_text {
    my ( $dest, $text, $stripped ) = @_;
        if ($text!~/Topic for .+:/) {
            Encode::from_to($text, $remote_charset, $local_charset );
        }
    Irssi::signal_continue( $dest, $text, $stripped );
}
Irssi::signal_add( 'print text', 'print_text' );

sub message_topic {
        my ( $server, $chan, $topic, $nick, $addr ) = @_;
        Encode::from_to($topic, $local_charset, $remote_charset );
        Irssi::signal_continue( $server, $chan, $topic, $nick, $addr );
}
Irssi::signal_add_first( 'message topic', 'message_topic' );

sub event_topic {
        my ($server, $data, $nick, $address) = @_;
        my ($channel, $topic) = split(/ :/, $data, 2);
        Encode::from_to($topic, $remote_charset, $local_charset );
        $data = "$channel :$topic";

        Irssi::signal_continue( $server, $data, $nick, $address );
}
Irssi::signal_add_first("event topic", "event_topic");
Irssi::signal_add_first("event 332", "event_topic");
Irssi::signal_add_first("event 333", "event_topic");

