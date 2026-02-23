import { useState } from 'react';
import { useNavigate, useParams } from 'react-router';
import { ChevronLeft, Phone, Camera, Plus } from 'lucide-react';
import { mockJobs } from '../data/mockData';
import { JobPhase, JobStatus } from '../types';
import { PhaseProgress } from '../components/PhaseProgress';
import { format } from 'date-fns';
import { motion } from 'motion/react';

const statusOptions: { value: JobStatus; label: string }[] = [
  { value: 'on-track', label: 'On Track' },
  { value: 'needs-attention', label: 'Needs Attention' },
  { value: 'behind', label: 'Behind Schedule' },
];

export function JobDetailScreen() {
  const navigate = useNavigate();
  const { id } = useParams();
  const job = mockJobs.find(j => j.id === id);
  const [currentPhase, setCurrentPhase] = useState(job?.currentPhase || 'demo');
  const [status, setStatus] = useState(job?.status || 'on-track');
  const [estimatedCompletion, setEstimatedCompletion] = useState(job?.estimatedCompletion ? format(job.estimatedCompletion, 'yyyy-MM-dd') : '');
  const [notes, setNotes] = useState(job?.notes || '');
  const [newNote, setNewNote] = useState('');

  if (!job) return <div className="min-h-screen bg-background flex items-center justify-center"><p className="text-muted-foreground">Job not found</p></div>;

  const handleAddNote = () => { if (newNote.trim()) { setNotes(notes ? `${newNote}\n\n---\n\n${notes}` : newNote); setNewNote(''); } };

  return (
    <div className="min-h-screen bg-background pb-24">
      <div className="max-w-[600px] mx-auto">
        <div className="sticky top-0 bg-background/70 backdrop-blur-2xl px-5 pt-14 pb-3 z-10">
          <button onClick={() => navigate('/jobs')} className="mb-3 text-system-blue active:opacity-70 flex items-center gap-0.5 -ml-1">
            <ChevronLeft className="w-5 h-5" /><span className="text-[17px]">Jobs</span>
          </button>
          <motion.h1 initial={{ opacity: 0, y: 8 }} animate={{ opacity: 1, y: 0 }} className="text-[34px] font-bold text-foreground tracking-tight">{job.clientName}</motion.h1>
          <p className="text-muted-foreground text-[15px] mt-0.5">{job.jobType}</p>
        </div>

        <div className="px-5 space-y-4 pt-2">
          {/* Phase */}
          <motion.div initial={{ opacity: 0, y: 8 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: 0.05 }} className="glass-elevated rounded-2xl p-4">
            <label className="block text-[11px] text-muted-foreground mb-3 uppercase tracking-wider">Phase</label>
            <PhaseProgress currentPhase={currentPhase} interactive onPhaseSelect={(p: JobPhase) => setCurrentPhase(p)} />
          </motion.div>

          {/* Completion + Status */}
          <motion.div initial={{ opacity: 0, y: 8 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: 0.1 }} className="glass-elevated rounded-2xl overflow-hidden divide-y divide-white/[0.04]">
            <div className="p-4">
              <label className="block text-[11px] text-muted-foreground mb-1 uppercase tracking-wider">Est. Completion</label>
              <input type="date" value={estimatedCompletion} onChange={(e) => setEstimatedCompletion(e.target.value)} className="w-full bg-transparent text-[17px] text-foreground focus:outline-none cursor-pointer" />
            </div>
            <div className="p-4">
              <label className="block text-[11px] text-muted-foreground mb-1 uppercase tracking-wider">Status</label>
              <select value={status} onChange={(e) => setStatus(e.target.value as JobStatus)} className="w-full bg-transparent text-[17px] text-foreground appearance-none focus:outline-none cursor-pointer">
                {statusOptions.map((o) => <option key={o.value} value={o.value}>{o.label}</option>)}
              </select>
            </div>
          </motion.div>

          {/* Photos */}
          <motion.div initial={{ opacity: 0, y: 8 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: 0.15 }}>
            <label className="block text-[11px] text-muted-foreground mb-3 uppercase tracking-wider">Photos</label>
            <div className="grid grid-cols-3 gap-2 mb-3">
              {[0, 1, 2].map(i => <div key={i} className="aspect-square glass-elevated rounded-2xl" />)}
            </div>
            <button className="w-full glass-elevated rounded-2xl p-4 flex items-center justify-center gap-2 active:bg-white/[0.02]">
              <Camera className="w-5 h-5 text-system-blue" /><span className="font-medium text-[15px] text-foreground">Add Photo</span>
            </button>
          </motion.div>

          {/* Notes */}
          <motion.div initial={{ opacity: 0, y: 8 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: 0.2 }}>
            <label className="block text-[11px] text-muted-foreground mb-3 uppercase tracking-wider">Notes</label>
            <textarea value={newNote} onChange={(e) => setNewNote(e.target.value)} placeholder="Add a note..." rows={3} className="w-full p-4 glass-elevated rounded-2xl resize-none focus:outline-none focus:ring-1 focus:ring-system-blue/50 text-foreground placeholder:text-muted-foreground text-[17px] mb-2" />
            <button onClick={handleAddNote} disabled={!newNote.trim()} className="px-4 py-2 bg-system-blue text-white rounded-xl text-[13px] font-semibold disabled:opacity-40 flex items-center gap-1">
              <Plus className="w-3.5 h-3.5" />Add
            </button>
            {notes && <div className="mt-3 p-4 glass-elevated rounded-2xl whitespace-pre-wrap text-foreground text-[15px]">{notes}</div>}
          </motion.div>

          {/* Call */}
          <motion.button whileTap={{ scale: 0.97 }} onClick={() => { window.location.href = `tel:${job.phone}`; }} className="w-full bg-system-blue text-white py-4 rounded-2xl text-[17px] font-semibold flex items-center justify-center gap-2">
            <Phone className="w-5 h-5" />Call {job.clientName}
          </motion.button>
        </div>
      </div>
    </div>
  );
}
