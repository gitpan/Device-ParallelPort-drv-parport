package Device::ParallelPort::drv::parport;
use strict;
use Carp;

=head1 NAME

Device::ParallelPort::drv::parport - Linux Kernel 2.2+ parport /dev/parport

=head1 DESCRIPTION

This program uses the linux /dev/parportX devices, which means of course that
you must have access to that device, which is simply a matter changing
permissions for your system, much the same as you would if you where giving the
user access to the sound card (eg: /dev/dsp)

=head1 NOTES

Note that this is a temporary hack for now, full version to come soon...

=cut

use Device::ParallelPort::drv;
require DynaLoader;
our @ISA = qw(Device::ParallelPort::drv DynaLoader);
our $VERSION = '0.1';

bootstrap Device::ParallelPort::drv::parport $VERSION;

# Standard function to return information from this driver
sub INFO {
	return {
		'os' => 'linux',
		'ver' => '>= 2.2',
		'type' => 'byte',
	};
}

sub init {
	my ($this, $str, @params) = @_;

	$this->{DATA}{DEVICE} = "/dev/parport" . $str;
	#if (-f "/dev/parport" . $str) {
	#	$this->{DATA}{DEVICE} = "/dev/parport" . $str;
	#} elsif (-f "/dev/ppuser" . $str) {
	#	# TODO - consider using sprintf for 00, 01 ...
	#	$this->{DATA}{DEVICE} = "/dev/ppuser" . $str;
	#} else {
	#	croak "No device found /dev/parport*, /dev/ppuser*";
	#}

	$this->{DATA}{BASE} = parport_opendev($this->{DATA}{DEVICE});
	unless ($this->{DATA}{BASE} > 1) {
		croak "Failed to load partport driver for " . $this->{DATA}{DEVICE};
	}
}

sub set_byte {
	my ($this, $byte, $val) = @_;
	if ($byte == $this->OFFSET_DATA()) {
		parport_wr_data($this->{DATA}{BASE}, $val);
	} elsif ($byte == $this->OFFSET_CONTROL()) {
		parport_wr_ctrl($this->{DATA}{BASE}, $val);
	} elsif ($byte == $this->OFFSET_STATUS()) {
		# parport_wr_status($this->{DATA}{BASE}, $val);
		croak "Unsupported - write to status line";
	} else {
		croak "drv:parport supports only byte 0,1 and 2";
	}
}

sub get_byte {
	my ($this, $byte, $val) = @_;
	if ($byte == $this->OFFSET_DATA()) {
		return parport_rd_data($this->{DATA}{BASE});
	} elsif ($byte == $this->OFFSET_CONTROL()) {
		return parport_rd_ctrl($this->{DATA}{BASE});
	} elsif ($byte == $this->OFFSET_STATUS()) {
		return parport_rd_status($this->{DATA}{BASE});
	} else {
		croak "drv:parport supports only byte 0,1 and 2";
	}
}

sub DESTROY {
	my ($this) = @_;
	if (defined($this->{DATA}{BASE})) {
		parport_closedev($this->{DATA}{BASE});
	}
}

1;

