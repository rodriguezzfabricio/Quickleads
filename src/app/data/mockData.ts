// Mock data for development
import { Lead, Job, AppSettings, Client } from '../types';

export const mockLeads: Lead[] = [
  {
    id: '1',
    name: 'Mike Johnson',
    phone: '301-555-0123',
    jobType: 'Deck',
    status: 'call-back-now',
    createdAt: new Date(2026, 1, 19, 10, 30),
    previousProjects: [
      {
        id: 'pp-1a',
        jobType: 'Fence',
        completedAt: new Date(2025, 8, 12),
        status: 'completed',
        notes: 'Cedar privacy fence, 120 linear ft.',
      },
    ],
  },
  {
    id: '2',
    name: 'Sarah Williams',
    phone: '240-555-0456',
    jobType: 'Kitchen',
    status: 'call-back-now',
    createdAt: new Date(2026, 1, 19, 14, 15),
  },
  {
    id: '3',
    name: 'Tom Anderson',
    phone: '301-555-0789',
    jobType: 'Bathroom',
    status: 'estimate-sent',
    createdAt: new Date(2026, 1, 17, 9, 0),
    contactedAt: new Date(2026, 1, 17, 16, 30),
    estimateSentAt: new Date(2026, 1, 17, 17, 0),
    followUpSequence: {
      active: true,
      day2Sent: false,
      day5Sent: false,
      day10Sent: false,
    },
  },
  {
    id: '4',
    name: 'Lisa Martinez',
    phone: '240-555-0321',
    jobType: 'Fence',
    status: 'estimate-sent',
    createdAt: new Date(2026, 1, 15, 11, 20),
    contactedAt: new Date(2026, 1, 15, 14, 0),
    estimateSentAt: new Date(2026, 1, 15, 15, 30),
    followUpSequence: {
      active: true,
      day2Sent: true,
      day5Sent: false,
      day10Sent: false,
    },
  },
  {
    id: '5',
    name: 'David Chen',
    phone: '301-555-0654',
    jobType: 'Basement',
    status: 'won',
    createdAt: new Date(2026, 1, 10, 8, 45),
    contactedAt: new Date(2026, 1, 10, 15, 0),
    estimateSentAt: new Date(2026, 1, 11, 10, 0),
    previousProjects: [
      {
        id: 'pp-5a',
        jobType: 'Kitchen',
        startedAt: new Date(2024, 3, 10),
        completedAt: new Date(2024, 4, 20),
        status: 'completed',
        notes: 'Full kitchen remodel, granite countertops and new cabinets.',
        photos: [
          'https://images.unsplash.com/photo-1556910103-1c02745a872f?auto=format&fit=crop&q=80&w=400',
          'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?auto=format&fit=crop&q=80&w=400'
        ],
      },
      {
        id: 'pp-5b',
        jobType: 'Deck',
        startedAt: new Date(2023, 5, 20),
        completedAt: new Date(2023, 6, 3),
        status: 'completed',
        notes: 'Composite deck, 400 sq ft with built-in lighting.',
        photos: [
          'https://images.unsplash.com/photo-1585827367800-47b744d21278?auto=format&fit=crop&q=80&w=400'
        ]
      },
    ],
  },
  {
    id: '6',
    name: 'Jennifer Brown',
    phone: '240-555-0987',
    jobType: 'Roof',
    status: 'cold',
    createdAt: new Date(2026, 1, 5, 13, 30),
    contactedAt: new Date(2026, 1, 5, 16, 0),
    estimateSentAt: new Date(2026, 1, 6, 9, 0),
  },
];

export const mockJobs: Job[] = [
  {
    id: 'j1',
    clientName: 'Robert Wilson',
    jobType: 'Kitchen',
    currentPhase: 'rough',
    status: 'on-track',
    estimatedCompletion: new Date(2026, 2, 15),
    createdAt: new Date(2026, 1, 1),
    lastUpdated: new Date(2026, 1, 18),
    phone: '301-555-1111',
    notes: 'Client wants granite countertops. Plumber scheduled for next week.',
  },
  {
    id: 'j2',
    clientName: 'Patricia Davis',
    jobType: 'Deck',
    currentPhase: 'finishing',
    status: 'needs-attention',
    estimatedCompletion: new Date(2026, 1, 25),
    createdAt: new Date(2026, 0, 15),
    lastUpdated: new Date(2026, 1, 16),
    phone: '240-555-2222',
    notes: 'Waiting on stain delivery. Should arrive tomorrow.',
  },
  {
    id: 'j3',
    clientName: 'James Miller',
    jobType: 'Bathroom',
    currentPhase: 'demo',
    status: 'behind',
    estimatedCompletion: new Date(2026, 1, 28),
    createdAt: new Date(2026, 1, 10),
    lastUpdated: new Date(2026, 1, 15),
    phone: '301-555-3333',
    notes: 'Found water damage behind walls. Need to address before continuing.',
  },
  {
    id: 'j4',
    clientName: 'Mary Garcia',
    jobType: 'Fence',
    currentPhase: 'electrical-plumbing',
    status: 'on-track',
    estimatedCompletion: new Date(2026, 2, 5),
    createdAt: new Date(2026, 1, 8),
    lastUpdated: new Date(2026, 1, 19),
    phone: '240-555-4444',
  },
  {
    id: 'j5',
    clientName: 'John Taylor',
    jobType: 'Addition',
    currentPhase: 'walkthrough',
    status: 'on-track',
    estimatedCompletion: new Date(2026, 1, 22),
    createdAt: new Date(2025, 11, 1),
    lastUpdated: new Date(2026, 1, 18),
    phone: '301-555-5555',
    notes: 'Final walkthrough scheduled for Friday.',
  },
];

export const defaultSettings: AppSettings = {
  businessName: 'ABC Construction',
  contractorName: 'John Smith',
  phone: '301-555-9999',
  followUpEnabled: true,
  followUpMethod: 'sms',
  followUpTemplates: [
    {
      day: 2,
      message: 'Hi {client_name}, just following up on the {job_type} estimate I sent over. Still interested? Happy to answer any questions. — {contractor_name}',
    },
    {
      day: 5,
      message: 'Hey {client_name}, wanted to check in about your {job_type} project. Let me know if you have any questions or if you\'d like to move forward. — {contractor_name}',
    },
    {
      day: 10,
      message: 'Hi {client_name}, this is my final follow-up on the {job_type} estimate. If you\'re still interested, I\'d love to help. Otherwise, feel free to reach out if plans change. — {contractor_name}',
    },
  ],
  notificationsEnabled: true,
};

export const mockClients: Client[] = [
  {
    id: 'c1',
    name: 'Robert Wilson',
    phone: '301-555-1111',
    email: 'rwilson@email.com',
    address: '142 Oak Street, Rockville, MD',
    notes: 'Prefers texts over calls. Referred by John Taylor.',
    createdAt: new Date(2025, 6, 10),
    previousProjects: [
      {
        id: 'pp-c1a',
        jobType: 'Kitchen',
        startedAt: new Date(2026, 0, 15),
        completedAt: new Date(2026, 2, 15),
        status: 'completed',
        notes: 'Full kitchen remodel with granite countertops.',
        photos: [
          'https://images.unsplash.com/photo-1556910103-1c02745a872f?auto=format&fit=crop&q=80&w=400'
        ]
      },
      {
        id: 'pp-c1b',
        jobType: 'Bathroom',
        startedAt: new Date(2025, 8, 10),
        completedAt: new Date(2025, 9, 3),
        status: 'completed',
        notes: 'Master bath renovation.',
        photos: [
          'https://images.unsplash.com/photo-1584622650111-993a426fbf0a?auto=format&fit=crop&q=80&w=400'
        ]
      },
    ],
  },
  {
    id: 'c2',
    name: 'Patricia Davis',
    phone: '240-555-2222',
    email: 'pdavis@email.com',
    address: '87 Maple Ave, Gaithersburg, MD',
    createdAt: new Date(2025, 0, 15),
    previousProjects: [
      {
        id: 'pp-c2a',
        jobType: 'Deck',
        completedAt: new Date(2025, 7, 20),
        status: 'completed',
        notes: 'Composite deck, 320 sq ft.',
      },
    ],
  },
  {
    id: 'c3',
    name: 'James Miller',
    phone: '301-555-3333',
    address: '23 Pine Rd, Silver Spring, MD',
    createdAt: new Date(2024, 10, 5),
    previousProjects: [
      {
        id: 'pp-c3a',
        jobType: 'Roof',
        completedAt: new Date(2025, 3, 12),
        status: 'completed',
      },
      {
        id: 'pp-c3b',
        jobType: 'Painting',
        completedAt: new Date(2024, 11, 20),
        status: 'completed',
        notes: 'Exterior full repaint.',
      },
    ],
  },
];
