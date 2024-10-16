=pod 

=head1 NAME

    Bio::EnsEMBL::Hive::Meadow::SGE

=head1 DESCRIPTION

    This is the 'SGE' implementation of Meadow

=head1 LICENSE

    Copyright [1999-2015] Wellcome Trust Sanger Institute and the EMBL-European Bioinformatics Institute
    Copyright [2016-2024] EMBL-European Bioinformatics Institute

    Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

         http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software distributed under the License
    is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and limitations under the License.

=head1 EXTERNAL CONTRIBUTION

This module has been written in collaboration between Lel Eory (University of Edinburgh) and Javier Herrero (University College London) based on the LSF.pm module. Hence keeping the same LICENSE note.

=head1 CONTACT

    Please subscribe to the Hive mailing list:  http://listserver.ebi.ac.uk/mailman/listinfo/ehive-users  to discuss Hive-related questions or to be notified of our updates

=cut


package Bio::EnsEMBL::Hive::Meadow::SGE;

use strict;
use warnings;
use XML::Simple;

use Bio::EnsEMBL::Hive::Utils ('split_for_bash');

use base ('Bio::EnsEMBL::Hive::Meadow');


our $VERSION = '5.0';       # Semantic version of the Meadow interface:
                            #   change the Major version whenever an incompatible change is introduced,
                            #   change the Minor version whenever the interface is extended, but compatibility is retained.


sub name {  # also called to check for availability; assume SGE is available if SGE cluster_name can be established

#    get cluster- or host-name that runs the SGE scheduler
    my $def_cluster = ($ENV{'SGE_ROOT'} // '') .'/'. ($ENV{'SGE_CELL'} // '') .'/common/cluster_name';
    my $cmd = ((-e $def_cluster) ? "cat $def_cluster" : "qconf -sss 2>/dev/null");

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
        if ($sge_jobindex > 0) {
            return "$sge_jobid\[$sge_jobindex\]";
        } else {
            return $sge_jobid;
        }
    } else {
        die "Could not establish the process_id";
    }
}


sub deregister_local_process {
    my ($self) = @_;

    delete $ENV{'JOB_ID'};
    delete $ENV{'SGE_TASK_ID'};
}


sub status_of_all_our_workers { # returns an arrayref
    my $self                        = shift @_;
    my $meadow_users_of_interest    = shift @_;

    $meadow_users_of_interest = [ '*' ] unless ($meadow_users_of_interest && scalar(@$meadow_users_of_interest));
#    warn "SGE::status_of_all_our_workers(jnp: $jnp, users: ".join("/",@$meadow_users_of_interest).")\n";

    my $jnp = $self->job_name_prefix();

    my @status_list = ();
    foreach my $meadow_user (@$meadow_users_of_interest) {
        my %workers = %{_get_job_hash($meadow_user)};
        while (my ($worker_pid, $worker_hash) =  each %workers) {
            warn("status: $worker_pid - ".$worker_hash->{'state'});
            my $job_name = $worker_hash->{'jobname'};

            # skip the hive jobs that belong to another pipeline
            next if (($job_name =~ /Hive-/) and (index($job_name, $jnp) != 0));

            push @status_list, [$worker_pid, $worker_hash->{'user'}, $worker_hash->{'state'}];
        }
    }

    return \@status_list;
}


sub check_worker_is_alive_and_mine {
    my ($self, $worker) = @_;

    my $wpid = $worker->process_id();
    my $this_user = $ENV{'USER'};
    my $workers = _get_job_hash($this_user);

    return exists $workers->{$wpid};
}


sub kill_worker {
    my ($self, $worker, $fast) = @_;

    my $wpid = $worker->process_id();

    my $cmd = 'qdel '.$wpid;

    system($cmd);
}


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
    my ($meadow_user) = @_;
    # TODO: Convert this into a global constant!
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

    my $qstat = join("", qx"qstat -g d -xml -u '$meadow_user'");
    #warn $qstat;
    # This command (qstat -g d -xml) outputs the status of the current jobs for the current user
    # in XML format. The "-g d" flag outputs the job arrays into single entries, which facilitates
    # parsing this information.
    #########################
    # Example output 1 (no jobs)
    # $ qstat -g d -xml
    # <?xml version='1.0'?>
    # <job_info  xmlns:xsd="http://www.w3.org/2001/XMLSchema">
    #   <queue_info>
    #   </queue_info>
    #   <job_info>
    #   </job_info>
    # </job_info>
    #########################
    # Example output 2 (one single job)
    # $ qstat -g d -xml
    # <?xml version='1.0'?>
    # <job_info  xmlns:xsd="http://www.w3.org/2001/XMLSchema">
    #   <queue_info>
    #     <job_list state="running">
    #       <JB_job_number>2188369</JB_job_number>
    #       <JAT_prio>0.50383</JAT_prio>
    #       <JB_name>lastz-Hive-default-1</JB_name>
    #       <JB_owner>regmher</JB_owner>
    #       <state>r</state>
    #       <JAT_start_time>2014-11-25T06:36:45</JAT_start_time>
    #       <queue_name>all.q@larry-3-32.local</queue_name>
    #       <slots>1</slots>
    #     </job_list>
    #   </queue_info>
    #   <job_info>
    #   </job_info>
    # </job_info>
    #########################
    # Example output 3 (several running jobs)
    # <?xml version='1.0'?>
    # <job_info  xmlns:xsd="http://www.w3.org/2001/XMLSchema">
    #   <queue_info>
    #     <job_list state="running">
    #       <JB_job_number>2188039</JB_job_number>
    #       <JAT_prio>0.50053</JAT_prio>
    #       <JB_name>lastz-Hive-default-1</JB_name>
    #       <JB_owner>regmher</JB_owner>
    #       <state>r</state>
    #       <JAT_start_time>2014-11-24T22:17:46</JAT_start_time>
    #       <queue_name>all.q@groucho-1-11.local</queue_name>
    #       <slots>1</slots>
    #       <tasks>2</tasks>
    #     </job_list>
    #   </queue_info>
    #   <job_info>
    #     <job_list state="pending">
    #       <JB_job_number>2188039</JB_job_number>
    #       <JAT_prio>0.50020</JAT_prio>
    #       <JB_name>lastz-Hive-default-1</JB_name>
    #       <JB_owner>regmher</JB_owner>
    #       <state>qw</state>
    #       <JB_submission_time>2014-11-24T22:17:07</JB_submission_time>
    #       <queue_name></queue_name>
    #       <slots>1</slots>
    #       <tasks>9</tasks>
    #     </job_list>
    #     <job_list state="pending">
    #       <JB_job_number>2188039</JB_job_number>
    #       <JAT_prio>0.50020</JAT_prio>
    #       <JB_name>lastz-Hive-default-1</JB_name>
    #       <JB_owner>regmher</JB_owner>
    #       <state>qw</state>
    #       <JB_submission_time>2014-11-24T22:17:07</JB_submission_time>
    #       <queue_name></queue_name>
    #       <slots>1</slots>
    #       <tasks>10</tasks>
    #     </job_list>
    #   </job_info>
    # </job_info>
    #########################

    my $tree = XMLin($qstat);

    my %all_jobs=();
    while (my ($key1, $value1) = each %$tree) {
        if (ref($value1) eq "HASH" and $value1->{"job_list"}) {
            my @jobs;
            if (ref($value1->{"job_list"}) eq "ARRAY") {
                @jobs = @{$value1->{"job_list"}};
            } else {
                @jobs = ($value1->{"job_list"});
            }
            foreach my $this_job (@jobs) {
                my $jobid = $this_job->{'JB_job_number'};
                my $taskid = $this_job->{'tasks'};
                my $jobkey = ($taskid ? $jobid."[$taskid]" : $jobid);
                my $state = $this_job->{'state'}[1];
                $all_jobs{$jobkey}->{'jobname'} = $this_job->{'JB_name'};
                $all_jobs{$jobkey}->{'user'} = $this_job->{'JB_owner'};
                $all_jobs{$jobkey}->{'state'} = ((exists $state_map{$state}) ? $state_map{$state} : 'UNKWN');
                $all_jobs{$jobkey}->{'queue'} = $this_job->{'queue_name'};
                $all_jobs{$jobkey}->{'slots'} = $this_job->{'slots'};
                $all_jobs{$jobkey}->{'taskid'} = $taskid;
            }
        }
    }

#    _print_job_list(\%all_jobs);
    return \%all_jobs; # returns hashref
}


sub submit_workers_return_meadow_pids {
    my ($self, $worker_cmd, $required_worker_count, $iteration, $rc_name, $rc_specific_submission_cmd_args, $submit_log_subdir) = @_;

    my $job_array_common_name               = $self->job_array_common_name($rc_name, $iteration);
    my $meadow_specific_submission_cmd_args = $self->config_get('SubmissionOptions');
    my $array_required                      = $required_worker_count > 1;

    my @cmd = ('qsub',
        '-b'    => 'y',                     # the command is to be treated "as a binary"
        '-V',                               # propagate all ENV variables to the submitted job (off by default)
        '-cwd',                             # execute the job from the current working directory
        '-N'    => $job_array_common_name,
        ($submit_log_subdir ? ('-o' => $submit_log_subdir, '-e' => $submit_log_subdir)  : ()),   # use default output/error names & include -cwd for relative path
        ($array_required    ? ('-t' => "1-${required_worker_count}")                    : ()),
        split_for_bash($rc_specific_submission_cmd_args),
        split_for_bash($meadow_specific_submission_cmd_args),
        split_for_bash($worker_cmd),
    );

    warn "Executing [ ".$self->signature." ] \t\t".join(' ', @cmd)."\n";

    my $sge_jobid;

    open(my $qsub_output_fh, "-|", @cmd) || die "Could not submit job(s): $!, $?";  # let's abort the beekeeper and let the user check the syntax
    while(my $line = <$qsub_output_fh>) {
        if($line=~/^your job(?:-array)? (\d+).+ has been submitted/i) {
            $sge_jobid = $1;
        } else {
            warn $line;     # assuming it is a temporary blockage that might resolve itself with time
        }
    }
    close $qsub_output_fh;

    if($sge_jobid) {
        return ($array_required ? [ map { $sge_jobid.'['.$_.']' } (1..$required_worker_count) ] : [ $sge_jobid ]);
    } else {
        die "Submission unsuccessful\n";
    }
}

1;
