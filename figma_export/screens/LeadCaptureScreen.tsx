import { useState } from 'react';
import { useNavigate } from 'react-router';
import { ChevronLeft, Mic } from 'lucide-react';
import { JobType } from '../types';
import { motion } from 'motion/react';

const jobTypes: JobType[] = ['Deck', 'Kitchen', 'Bathroom', 'Roof', 'Fence', 'Basement', 'Addition', 'Painting', 'Concrete', 'Other'];

export function LeadCaptureScreen() {
  const navigate = useNavigate();
  const [name, setName] = useState('');
  const [phone, setPhone] = useState('');
  const [jobType, setJobType] = useState<JobType | string>('');
  const [showQuickText, setShowQuickText] = useState(false);
  const [quickText, setQuickText] = useState('');
  const [otherJobType, setOtherJobType] = useState('');

  const handleSave = () => { navigate('/'); };
  const canSave = name.trim() && phone.trim() && (jobType !== 'Other' ? jobType : otherJobType.trim());

  if (showQuickText) {
    return (
      <div className="min-h-screen bg-background px-5 pt-14">
        <div className="max-w-[600px] mx-auto">
          <button onClick={() => setShowQuickText(false)} className="mb-6 text-system-blue flex items-center gap-0.5 -ml-1">
            <ChevronLeft className="w-5 h-5" /><span className="text-[17px]">Back</span>
          </button>
          <h1 className="text-[34px] font-bold mb-2 text-foreground tracking-tight">Quick Capture</h1>
          <p className="text-muted-foreground text-[15px] mb-6">Type it like a text. We'll sort it out.</p>
          <textarea value={quickText} onChange={(e) => setQuickText(e.target.value)} placeholder='e.g., John 301-555-2847 deck' className="w-full h-40 text-[17px] p-4 glass-elevated rounded-2xl resize-none focus:outline-none focus:ring-1 focus:ring-system-blue/50 text-foreground placeholder:text-muted-foreground" autoFocus />
          <motion.button whileTap={{ scale: 0.97 }} onClick={handleSave} disabled={!quickText.trim()} className="w-full bg-system-blue text-white py-4 rounded-2xl text-[17px] font-semibold mt-4 disabled:opacity-40">
            Save Lead
          </motion.button>
        </div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-background px-5 pt-14">
      <div className="max-w-[600px] mx-auto">
        <button onClick={() => navigate('/')} className="mb-6 text-system-blue flex items-center gap-0.5 -ml-1">
          <ChevronLeft className="w-5 h-5" /><span className="text-[17px]">Cancel</span>
        </button>
        <motion.h1 initial={{ opacity: 0, y: 8 }} animate={{ opacity: 1, y: 0 }} className="text-[34px] font-bold mb-8 text-foreground tracking-tight">New Lead</motion.h1>

        <div className="space-y-4 mb-6">
          <div>
            <label className="block text-[11px] text-muted-foreground mb-1 uppercase tracking-wider">Name</label>
            <input type="text" value={name} onChange={(e) => setName(e.target.value)} placeholder="Client name" className="w-full text-[17px] p-4 glass-elevated rounded-2xl focus:outline-none focus:ring-1 focus:ring-system-blue/50 text-foreground placeholder:text-muted-foreground" autoFocus />
          </div>
          <div>
            <label className="block text-[11px] text-muted-foreground mb-1 uppercase tracking-wider">Phone</label>
            <input type="tel" value={phone} onChange={(e) => setPhone(e.target.value)} placeholder="Phone number" className="w-full text-[17px] p-4 glass-elevated rounded-2xl focus:outline-none focus:ring-1 focus:ring-system-blue/50 text-foreground placeholder:text-muted-foreground" />
          </div>
        </div>

        <label className="block text-[11px] text-muted-foreground mb-3 uppercase tracking-wider">What They Need</label>
        <div className="flex flex-wrap gap-2 mb-4">
          {jobTypes.map((type) => (
            <motion.button key={type} whileTap={{ scale: 0.95 }} onClick={() => setJobType(type)}
              className={`px-4 py-2.5 rounded-full text-[15px] font-medium transition-all duration-300 ${jobType === type ? 'bg-system-blue text-white' : 'glass-elevated text-foreground'
                }`}
            >{type}</motion.button>
          ))}
        </div>
        {jobType === 'Other' && (
          <input type="text" value={otherJobType} onChange={(e) => setOtherJobType(e.target.value)} placeholder="Describe..." className="w-full text-[17px] p-4 glass-elevated rounded-2xl focus:outline-none focus:ring-1 focus:ring-system-blue/50 text-foreground placeholder:text-muted-foreground mb-4" />
        )}

        <button onClick={() => setShowQuickText(true)} className="w-full glass-elevated rounded-2xl p-4 mb-6 flex items-center justify-center gap-2">
          <Mic className="w-5 h-5 text-system-blue" /><span className="text-foreground font-medium text-[15px]">Or just text it</span>
        </button>

        <motion.button whileTap={{ scale: 0.97 }} onClick={handleSave} disabled={!canSave} className="w-full bg-system-blue text-white py-4 rounded-2xl text-[17px] font-semibold disabled:opacity-40">
          Save Lead
        </motion.button>
      </div>
    </div>
  );
}