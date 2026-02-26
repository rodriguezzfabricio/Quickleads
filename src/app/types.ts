// Type definitions for the ContractorComm app

export type LeadStatus = 'call-back-now' | 'estimate-sent' | 'won' | 'cold';

export interface PreviousProject {
  id: string;
  jobType: JobType | string;
  startedAt?: Date;
  completedAt: Date;
  status: 'completed' | 'cancelled';
  notes?: string;
  photos?: string[];
}

export type JobStatus = 'on-track' | 'needs-attention' | 'behind';

export type JobPhase = 'demo' | 'rough' | 'electrical-plumbing' | 'finishing' | 'walkthrough' | 'complete';

export type JobType = 'Deck' | 'Kitchen' | 'Bathroom' | 'Roof' | 'Fence' | 'Basement' | 'Addition' | 'Painting' | 'Concrete' | 'Other';

export interface Lead {
  id: string;
  name: string;
  phone: string;
  jobType: JobType | string;
  status: LeadStatus;
  createdAt: Date;
  contactedAt?: Date;
  estimateSentAt?: Date;
  /** Raw shorthand text captured when user uses quick-entry mode */
  quickCaptureText?: string;
  notes?: string;
  email?: string;
  address?: string;
  followUpSequence?: {
    active: boolean;
    day2Sent: boolean;
    day5Sent: boolean;
    day10Sent: boolean;
    pausedAt?: Date;
  };
  previousProjects?: PreviousProject[];
}

export interface Client {
  id: string;
  name: string;
  phone: string;
  email?: string;
  address?: string;
  notes?: string;
  createdAt: Date;
  previousProjects: PreviousProject[];
  /** The lead ID this client was converted from, if any */
  fromLeadId?: string;
}

export interface Job {
  id: string;
  clientName: string;
  jobType: JobType | string;
  currentPhase: JobPhase;
  status: JobStatus;
  estimatedCompletion: Date;
  createdAt: Date;
  lastUpdated: Date;
  notes?: string;
  phone: string;
  photos?: string[];
  /** The lead ID this job was created from, if any */
  leadId?: string;
}

export interface FollowUpTemplate {
  day: number;
  message: string;
}

export interface UnknownCall {
  id: string;
  phone: string;
  calledAt: Date;
  durationSeconds?: number;
  direction?: 'incoming' | 'outgoing';
}

export interface AppSettings {
  businessName: string;
  contractorName: string;
  phone: string;
  followUpEnabled: boolean;
  followUpMethod: 'sms' | 'email' | 'both';
  followUpTemplates: FollowUpTemplate[];
  notificationsEnabled: boolean;
}
