import { createContext, useContext, useMemo, useState } from 'react';
import { mockJobs, mockLeads, mockUnknownCalls } from '../data/mockData';
import { Job, JobPhase, JobStatus, Lead, LeadStatus, UnknownCall } from '../types';

interface CreateJobInput {
  clientName: string;
  phone: string;
  jobType: string;
  estimatedCompletion: Date;
  currentPhase: JobPhase;
  status: JobStatus;
  leadId?: string;
}

interface CreateLeadInput {
  name?: string;
  phone?: string;
  jobType?: string;
  quickCaptureText?: string;
}

interface LeadsContextValue {
  leads: Lead[];
  jobs: Job[];
  unknownCalls: UnknownCall[];
  wonLeadsWithoutProject: Lead[];
  updateLeadStatus: (leadId: string, status: LeadStatus) => void;
  markEstimateSent: (leadId: string) => void;
  markLeadWon: (leadId: string) => void;
  createJob: (input: CreateJobInput) => Job;
  createLead: (input: CreateLeadInput) => Lead;
  pauseFollowUps: (leadId: string) => void;
  stopFollowUps: (leadId: string) => void;
  deleteLead: (leadId: string) => void;
  markLeadCold: (leadId: string) => void;
  skipUnknownCall: (callId: string) => void;
}

const LeadsContext = createContext<LeadsContextValue | undefined>(undefined);

export function LeadsProvider({ children }: { children: React.ReactNode }) {
  const [leads, setLeads] = useState<Lead[]>(mockLeads);
  const [jobs, setJobs] = useState<Job[]>(mockJobs);
  const [unknownCalls, setUnknownCalls] = useState<UnknownCall[]>(mockUnknownCalls);

  // Keep status updates centralized so list/detail/home stay in sync.
  const updateLeadStatus = (leadId: string, status: LeadStatus) => {
    setLeads((currentLeads) =>
      currentLeads.map((lead) => (lead.id === leadId ? { ...lead, status } : lead)),
    );
  };

  // "Estimate Sent?" is the single source of truth for activating follow-ups.
  const markEstimateSent = (leadId: string) => {
    setLeads((currentLeads) =>
      currentLeads.map((lead) => {
        if (lead.id !== leadId || lead.status !== 'call-back-now') return lead;
        return {
          ...lead,
          status: 'estimate-sent',
          estimateSentAt: new Date(),
          followUpSequence: {
            active: true,
            day2Sent: false,
            day5Sent: false,
            day10Sent: false,
          },
        };
      }),
    );
  };

  const createLead = (input: CreateLeadInput) => {
    const newLead: Lead = {
      id: `lead-${Date.now()}`,
      name: input.name?.trim() || 'Unparsed Lead',
      phone: input.phone?.trim() || 'Not provided',
      jobType: input.jobType?.trim() || 'Unspecified',
      quickCaptureText: input.quickCaptureText?.trim(),
      status: 'call-back-now',
      createdAt: new Date(),
    };
    setLeads((currentLeads) => [newLead, ...currentLeads]);
    return newLead;
  };

  // Winning a lead should always stop follow-ups immediately.
  const markLeadWon = (leadId: string) => {
    setLeads((currentLeads) =>
      currentLeads.map((lead) => {
        if (lead.id !== leadId) return lead;
        return {
          ...lead,
          status: 'won',
          followUpSequence: lead.followUpSequence
            ? { ...lead.followUpSequence, active: false }
            : undefined,
        };
      }),
    );
  };

  const pauseFollowUps = (leadId: string) => {
    setLeads((currentLeads) =>
      currentLeads.map((lead) => {
        if (lead.id !== leadId || !lead.followUpSequence) return lead;
        return {
          ...lead,
          followUpSequence: {
            ...lead.followUpSequence,
            active: false,
            pausedAt: new Date(),
          },
        };
      }),
    );
  };

  const stopFollowUps = (leadId: string) => {
    setLeads((currentLeads) =>
      currentLeads.map((lead) => {
        if (lead.id !== leadId || !lead.followUpSequence) return lead;
        return {
          ...lead,
          followUpSequence: {
            ...lead.followUpSequence,
            active: false,
            pausedAt: undefined,
          },
        };
      }),
    );
  };

  const deleteLead = (leadId: string) => {
    setLeads((currentLeads) => currentLeads.filter((lead) => lead.id !== leadId));
  };

  const markLeadCold = (leadId: string) => {
    setLeads((currentLeads) =>
      currentLeads.map((lead) => {
        if (lead.id !== leadId) return lead;
        return {
          ...lead,
          status: 'cold',
          followUpSequence: lead.followUpSequence
            ? { ...lead.followUpSequence, active: false, pausedAt: undefined }
            : undefined,
        };
      }),
    );
  };

  const skipUnknownCall = (callId: string) => {
    setUnknownCalls((currentCalls) => currentCalls.filter((call) => call.id !== callId));
  };

  // New project creation writes once to shared jobs state for dashboard/jobs list.
  const createJob = (input: CreateJobInput) => {
    const newJob: Job = {
      id: `job-${Date.now()}`,
      clientName: input.clientName,
      phone: input.phone,
      jobType: input.jobType,
      estimatedCompletion: input.estimatedCompletion,
      currentPhase: input.currentPhase,
      status: input.status,
      createdAt: new Date(),
      lastUpdated: new Date(),
      leadId: input.leadId,
    };
    setJobs((currentJobs) => [newJob, ...currentJobs]);
    return newJob;
  };

  // Reminder source: won leads that still have no linked project.
  const wonLeadsWithoutProject = useMemo(
    () =>
      leads.filter(
        (lead) => lead.status === 'won' && !jobs.some((job) => job.leadId === lead.id),
      ),
    [leads, jobs],
  );

  const value = useMemo(
    () => ({
      leads,
      jobs,
      unknownCalls,
      wonLeadsWithoutProject,
      updateLeadStatus,
      markEstimateSent,
      markLeadWon,
      createJob,
      createLead,
      pauseFollowUps,
      stopFollowUps,
      deleteLead,
      markLeadCold,
      skipUnknownCall,
    }),
    [leads, jobs, unknownCalls, wonLeadsWithoutProject],
  );

  return <LeadsContext.Provider value={value}>{children}</LeadsContext.Provider>;
}

export function useLeads() {
  const context = useContext(LeadsContext);
  if (!context) throw new Error('useLeads must be used within LeadsProvider');
  return context;
}
