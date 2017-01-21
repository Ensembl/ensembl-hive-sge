=pod 

=head1 NAME

    Bio::EnsEMBL::Hive::Meadow::SGE

=head1 DESCRIPTION

    This is the 'SGE' implementation of Meadow

=head1 LICENSE

    Copyright [1999-2014] Wellcome Trust Sanger Institute and the EMBL-European Bioinformatics Institute

    Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

         http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software distributed under the License
    is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and limitations under the License.

=head1 CONTACT

    Please subscribe to the Hive mailing list:  http://listserver.ebi.ac.uk/mailman/listinfo/ehive-users  to discuss Hive-related questions or to be notified of our updates

=cut


package Bio::EnsEMBL::Hive::Meadow::SGE;

use strict;

use base ('Bio::EnsEMBL::Hive::Meadow');


sub name {  # also called to check for availability; assume SGE is available if SGE cluster_name can be established

#    get cluster- or host-name that runs the SGE scheduler
    my $def_cluster = "$ENV{'SGE_ROOT'}/$ENV{'SGE_CELL'}/common/cluster_name";
    my $cmd = ((-e $def_cluster) ? "cat $def_cluster" : "qconf -sss");

#    warn "SGE::name() running cmd:\n\t$cmd\n";
    if(my $name = `$cmd`) {
        chomp($name);
        return $name;
    }
}


sub get_current_worker_process_id {
    my ($self) = @_;

    my $sge_jobid    = $ENV{'JOB_ID'};
    my $sge_jobindex = $ENV{'SGE_TASK_ID'};
#    warn "SGE::get_current_worker_process_id():\n\tjobid: $sge_jobid\n\tjobindex: $sge_jobindex\n";
    if(defined($sge_jobid) and defined($sge_jobindex)) {
        if($sge_jobindex>0) {
            return "$sge_jobid\[$sge_jobindex\]";
        } else {
            return $sge_jobid;
        }
    } else {
        die "Could not establish the process_id";
    }
}


sub count_pending_workers_by_rc_name {
    my ($self) = @_;

    my $jnp = $self->job_name_prefix();
#    warn "SGE::count_pending_workers_by_rc_name(jnp: $jnp)\n";
    
    my %pending_this_meadow_by_rc_name = ();
    my $total_pending_this_meadow = 0;
    
    my %workers = %{_get_job_hash($jnp)};
    foreach my $worker (values %workers){
        if($worker->{'state'} eq 'PEND' && $worker->{'jobname'}=~/\Q$jnp\E(\S+)\-\d+/) {
#            print "RC: $1\n";
            $pending_this_meadow_by_rc_name{$1}++;
            $total_pending_this_meadow++;
        }
    }

#    print "Total pending in meadow: $total_pending_this_meadow\n";
    return (\%pending_this_meadow_by_rc_name, $total_pending_this_meadow);
}


sub count_running_workers {
    my ($self) = @_;

    my $jnp = $self->job_name_prefix();
    
#    warn "SGE::count_running_workers(jnp: $jnp)\n";

    my $run_count = 0;

    my %workers = %{_get_job_hash($jnp)};
    foreach my $worker (values %workers){
        $run_count++ if($worker->{'state'} eq 'RUN');
    }

#    print "Num running in meadow: $run_count\n";

    return $run_count;
}


sub status_of_all_our_workers { 
    my ($self) = @_;

    my $jnp = $self->job_name_prefix();
    my %workers = %{_get_job_hash($jnp)};
    my %status_hash = ();
    while (my ($worker_pid, $worker_hash) = each %workers) {
       warn("status: $worker_pid - ".$worker_hash->{'state'});
       $status_hash{$worker_pid} = $worker_hash->{'state'};
    }
    return \%status_hash;
}


sub check_worker_is_alive_and_mine {
    my ($self, $worker) = @_;
    my $jnp = $self->job_name_prefix();
    my $wpid = $worker->process_id();
    my $this_user = $ENV{'USER'};
    my %workers = %{_get_job_hash($jnp)};
#    my $cmd = qq{bjobs $wpid -u $this_user 2>&1 | grep -v 'not found' | grep -v JOBID | grep -v EXIT};
    my %worker = %{$workers{$wpid}};
#    warn "SGE::check_worker_is_alive_and_mine($wpid - $this_user)\n";
    return ($worker->{'user'} eq $this_user);
}


sub kill_worker {
    my $worker = pop @_;
#    my ($wpid, $wtid)=split('[', $worker->process_id());
    my $wpid = $worker->process_id();
    #my $cmd = 'bkill '.$worker->process_id();
    my $cmd = 'qdel '.$wpid;
#    $cmd .= " -t $1" if($wtid =~ /(\d+)\]/);
#    warn "SGE::kill_worker() running cmd:\n\t$cmd\n";

    system($cmd);
}


#sub find_out_causes {
#    my $self = shift @_;
#
#    my %lsf_2_hive = (
#        'TERM_MEMLIMIT' => 'MEMLIMIT',
#        'TERM_RUNLIMIT' => 'RUNLIMIT',
#        'TERM_OWNER'    => 'KILLED_BY_USER',
#    );
#
#    my %cod = ();
#
#    while (my $pid_batch = join(' ', map { "'$_'" } splice(@_, 0, 20))) {  # can't fit too many pids on one shell cmdline
#        my $cmd = "bacct -l $pid_batch";
#
##        warn "SGE::find_out_causes() running cmd:\n\t$cmd\n";
#
#        foreach my $section (split(/\-{10,}\s+/, `$cmd`)) {
#            if($section=~/^Job <(\d+(?:\[\d+\])?)>.+(TERM_MEMLIMIT|TERM_RUNLIMIT|TERM_OWNER): job killed/) {
#                $cod{$1} = $lsf_2_hive{$2};
#            }
#        }
#    }
#
#    return \%cod;
#}


sub _print_job_list { # private sub to print job info from hashref
    my ($jobs) = @_;

    while(my ($jobid, $jobhash) = each %{$jobs}){
        my $out_str = "$jobid\t".$jobhash->{'jobname'}."\t".$jobhash->{'user'}."\t".$jobhash->{'state'}."\t";
        $out_str .= $jobhash->{'queue'} if($jobhash->{'queue'});
        $out_str .= (($jobhash->{'slots'}) ? "$jobhash->{'slots'}" : "\t");
        print "$out_str\n";
    }
}


sub _get_job_hash { # private sub to fetch job info in a hash with LSF-like statuses
    my ($job_name_prefix) = @_;
    # map possible/quasi states between SGE and LSF
    my %state_map = (); 
    $state_map{qw} = $state_map{hqw} = $state_map{hRwq} = 'PEND';
    $state_map{r} = $state_map{t} = $state_map{Rr} = $state_map{Rt} = 'RUN';
    $state_map{s} = $state_map{ts} = $state_map{S} = $state_map{tS} = 'SUSP';
    $state_map{T} = $state_map{tT} = $state_map{Rs} = $state_map{Rts} = 'SUSP';
    $state_map{RS} = $state_map{RtS} = $state_map{RT} = $state_map{RtT} = 'SUSP';
    $state_map{Eqw} = $state_map{Ehqw} = $state_map{EhRqw} = 'ERROR';
    $state_map{dr} = $state_map{dt} = $state_map{dRr} = $state_map{dRt} = 'DEL';
    $state_map{ds} = $state_map{dS} = $state_map{dT} = $state_map{dRs} = 'DEL';
    $state_map{dRS} = $state_map{dRT} = 'DEL';

    my $cmd = qq(qstat -j "$job_name_prefix*" | grep "job_number\\|job_name" | sed ':a;N;s/job_number: *\\([0-9-]\\+\\)\\n/\\1 /' | sed 's/job_name: *//');
#    warn "Execute command: $cmd\n";

    my %jobs=();
    foreach my $line (`$cmd`){
        my ($jid, $jobname) = split(/\s+/, $line);
        $jobs{$jid} = $jobname;
    }

    $cmd = 'qstat -u "*" -g d'; 
    my %all_jobs = (); 
    foreach my $line (`$cmd`){
        if($line =~ /^(\d+)\s+([.0-9]+)\s+(\S+)\s+(\w+)\s+(\w+)\s+([0-9\/]+ [0-9:]+)\s(\w+@\S+)?\s+(\d+)\s+(\d+)?\s*$/){
        my($jobid, $prior, $name, $user, $state, $submit, $queue, $slots, $taskid)=($1, $2, $3, $4, $5, $6, $7, $8, $9);
            if(exists $jobs{$jobid}){
                my $jobkey = ($taskid ? $jobid."[$taskid]" : $jobid);
                %{$all_jobs{$jobkey}} = (); 
                $all_jobs{$jobkey}->{'jobname'} = $jobs{$jobid};
                $all_jobs{$jobkey}->{'user'} = $user;
                $all_jobs{$jobkey}->{'state'} = ((exists $state_map{$state}) ? $state_map{$state} : 'UNKWN');
                $all_jobs{$jobkey}->{'queue'} = $queue;
                $all_jobs{$jobkey}->{'slots'} = $slots;
                $all_jobs{$jobkey}->{'taskid'} = $taskid;
            }   
        }   
    }
#    _print_job_list(\%all_jobs);
    return \%all_jobs;
}


sub submit_workers {

    my ($self, $worker_cmd, $required_worker_count, $iteration, $rc_name, $rc_specific_submission_cmd_args, $submit_log_subdir) = @_;
    my $job_name                            = $self->job_array_common_name($rc_name, $iteration);
    my $meadow_specific_submission_cmd_args = $self->config_get('SubmissionOptions');
    my $arr_job_args = (($required_worker_count > 1) ? "-t 1-${required_worker_count}" : '');
    my $log_stream_args = ($submit_log_subdir ? "-o $submit_log_subdir -e $submit_log_subdir" : ''); # use default output/error names & include -cwd for relative path

    my $cmd = qq{qsub -b y -cwd $log_stream_args -N "${job_name}" $arr_job_args $rc_specific_submission_cmd_args $meadow_specific_submission_cmd_args $worker_cmd};

#    warn "SGE::submit_workers() running cmd:\n\t$cmd\n";

    system($cmd) && die "Could not submit job(s): $!, $?";  # let's abort the beekeeper and let the user check the syntax

}

1;

