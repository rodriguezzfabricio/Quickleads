import { useState } from 'react';
import { useNavigate, useParams } from 'react-router';
import { ChevronLeft, Phone, MessageSquare, ChevronDown, ChevronUp, Pause } from 'lucide-react';
import { mockLeads } from '../data/mockData';
import { LeadStatus } from '../types';
import { motion } from 'motion/react';

const statusOptions: { value: LeadStatus; label: string }[] = [
  { value: 'call-back-now', label: 'New / Call Back' },
  { value: 'estimate-sent', label: 'Estimate Sent' },
  { value: 'won', label: 'Won' },
  { value: 'cold', label: 'Cold' },
];

export function LeadDetailScreen() {
  const navigate = useNavigate();
  const { id } = useParams();
  const lead = mockLeads.find(l => l.id === id);
  const [status, setStatus] = useState(lead?.status || 'call-back-now');
  const [showDetails, setShowDetails] = useState(false);
  const [notes, setNotes] = useState(lead?.notes || '');
  const [email, setEmail] = useState(lead?.email || '');
  const [address, setAddress] = useState(lead?.address || '');

  if (!lead) return <div className="min-h-screen bg-background flex items-center justify-center"><p className="text-muted-foreground">Lead not found</p></div>;

  const handleCallNow = () => { window.location.href = `tel:${lead.phone}`; };
  const handleSendText = () => { window.location.href = `sms:${lead.phone}`; };
  const handleMarkAsWon = () => { setStatus('won'); setTimeout(() => navigate('/'), 500); };

  return (
    <div className="min-h-screen bg-background pb-24">
      <div className="max-w-[600px] mx-auto">
        <div className="sticky top-0 bg-background/70 backdrop-blur-2xl px-5 pt-14 pb-3 z-10">
          <button onClick={() => navigate('/leads')} className="mb-3 text-system-blue active:opacity-70 flex items-center gap-0.5 -ml-1">
            <ChevronLeft className="w-5 h-5" /><span className="text-[17px]">Leads</span>
          </button>
          <motion.h1 initial={{ opacity: 0, y: 8 }} animate={{ opacity: 1, y: 0 }} className="text-[34px] font-bold text-foreground tracking-tight">{lead.name}</motion.h1>
        </div>

        <div className="px-5 space-y-4 pt-2">
          {/* Contact */}
          <motion.div initial={{ opacity: 0, y: 8 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: 0.05 }} className="glass-elevated rounded-2xl overflow-hidden">
            <button onClick={handleCallNow} className="w-full flex items-center gap-3 p-4 active:bg-white/[0.02] transition-colors">
              <Phone className="w-5 h-5 text-system-blue" /><span className="text-[17px] text-foreground">{lead.phone}</span>
            </button>
          </motion.div>

          {/* Job Type + Status */}
          <motion.div initial={{ opacity: 0, y: 8 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: 0.1 }} className="glass-elevated rounded-2xl overflow-hidden divide-y divide-white/[0.04]">
            <div className="p-4">
              <label className="block text-[11px] text-muted-foreground mb-1 uppercase tracking-wider">Job Type</label>
              <span className="text-[17px] text-foreground">{lead.jobType}</span>
            </div>
            <div className="p-4">
              <label className="block text-[11px] text-muted-foreground mb-1 uppercase tracking-wider">Status</label>
              <select value={status} onChange={(e) => setStatus(e.target.value as LeadStatus)} className="w-full bg-transparent text-[17px] text-foreground appearance-none focus:outline-none cursor-pointer">
                {statusOptions.map((o) => <option key={o.value} value={o.value}>{o.label}</option>)}
              </select>
            </div>
          </motion.div>

          {/* Follow-up */}
          {lead.followUpSequence?.active && (
            <motion.div initial={{ opacity: 0, y: 8 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: 0.15 }} className="glass-elevated rounded-2xl p-4">
              <div className="flex items-center justify-between mb-3">
                <h3 className="font-semibold text-[15px] text-system-blue">Follow-up Active</h3>
                <button className="text-system-blue text-[13px] font-medium flex items-center gap-1"><Pause className="w-3.5 h-3.5" />Pause</button>
              </div>
              <div className="space-y-2 text-[15px]">
                {[{ label: 'Day 2', sent: lead.followUpSequence.day2Sent }, { label: 'Day 5', sent: lead.followUpSequence.day5Sent }, { label: 'Day 10', sent: lead.followUpSequence.day10Sent }].map(d => (
                  <div key={d.label} className={`flex items-center gap-2 ${d.sent ? 'text-system-green' : 'text-muted-foreground'}`}>
                    <span className="font-medium">{d.label}:</span><span>{d.sent ? '✓ Sent' : '⏳ Scheduled'}</span>
                  </div>
                ))}
              </div>
            </motion.div>
          )}

          {/* Details */}
          <motion.div initial={{ opacity: 0, y: 8 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: 0.2 }}>
            <button onClick={() => setShowDetails(!showDetails)} className="w-full flex items-center justify-between p-4 glass-elevated rounded-2xl">
              <span className="font-medium text-[17px] text-foreground">Details</span>
              {showDetails ? <ChevronUp className="w-5 h-5 text-muted-foreground" /> : <ChevronDown className="w-5 h-5 text-muted-foreground" />}
            </button>
            {showDetails && (
              <motion.div initial={{ opacity: 0, height: 0 }} animate={{ opacity: 1, height: 'auto' }} className="mt-3 space-y-3">
                {[{ label: 'Email', val: email, set: setEmail, type: 'email', ph: 'Email (optional)' }, { label: 'Address', val: address, set: setAddress, type: 'text', ph: 'Address (optional)' }].map(f => (
                  <div key={f.label}>
                    <label className="block text-[11px] text-muted-foreground mb-1 uppercase tracking-wider">{f.label}</label>
                    <input type={f.type} value={f.val} onChange={(e) => f.set(e.target.value)} placeholder={f.ph} className="w-full p-4 glass-elevated rounded-2xl focus:outline-none focus:ring-1 focus:ring-system-blue/50 text-foreground placeholder:text-muted-foreground text-[17px]" />
                  </div>
                ))}
                <div>
                  <label className="block text-[11px] text-muted-foreground mb-1 uppercase tracking-wider">Notes</label>
                  <textarea value={notes} onChange={(e) => setNotes(e.target.value)} placeholder="Add notes..." rows={3} className="w-full p-4 glass-elevated rounded-2xl resize-none focus:outline-none focus:ring-1 focus:ring-system-blue/50 text-foreground placeholder:text-muted-foreground text-[17px]" />
                </div>
              </motion.div>
            )}
          </motion.div>

          {/* Actions */}
          <motion.div initial={{ opacity: 0, y: 8 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: 0.25 }} className="space-y-3 pt-2">
            <motion.button whileTap={{ scale: 0.97 }} onClick={handleCallNow} className="w-full bg-system-blue text-white py-4 rounded-2xl text-[17px] font-semibold flex items-center justify-center gap-2">
              <Phone className="w-5 h-5" />Call Now
            </motion.button>
            <motion.button whileTap={{ scale: 0.97 }} onClick={handleSendText} className="w-full glass-prominent text-foreground py-4 rounded-2xl text-[17px] font-semibold flex items-center justify-center gap-2">
              <MessageSquare className="w-5 h-5" />Send Text
            </motion.button>
            {status !== 'won' && (
              <motion.button whileTap={{ scale: 0.97 }} onClick={handleMarkAsWon} className="w-full bg-system-green text-white py-4 rounded-2xl text-[17px] font-semibold">
                Mark as Won
              </motion.button>
            )}
          </motion.div>
        </div>
      </div>
    </div>
  );
}