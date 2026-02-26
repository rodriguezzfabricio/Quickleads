import { useState } from 'react';
import { useNavigate, useSearchParams } from 'react-router';
import { ChevronLeft, Plus, X, CheckCircle2 } from 'lucide-react';
import { JobType } from '../types';
import { motion, AnimatePresence } from 'motion/react';

const jobTypes: JobType[] = [
    'Deck', 'Kitchen', 'Bathroom', 'Roof', 'Fence',
    'Basement', 'Addition', 'Painting', 'Concrete', 'Other',
];

interface ProjectDraft {
    id: string;
    jobType: string;
    completedAt: string;
    notes: string;
}

export function AddClientScreen() {
    const navigate = useNavigate();
    const [searchParams] = useSearchParams();

    // Pre-fill from lead if coming from "Add as Client" in leads
    const prefillName = searchParams.get('name') || '';
    const prefillPhone = searchParams.get('phone') || '';

    const [name, setName] = useState(prefillName);
    const [phone, setPhone] = useState(prefillPhone);
    const [email, setEmail] = useState('');
    const [address, setAddress] = useState('');
    const [notes, setNotes] = useState('');

    // Projects
    const [projects, setProjects] = useState<ProjectDraft[]>([]);
    const [addingProject, setAddingProject] = useState(false);
    const [draftJobType, setDraftJobType] = useState<string>('');
    const [draftDate, setDraftDate] = useState('');
    const [draftNotes, setDraftNotes] = useState('');

    const canSave = name.trim() && phone.trim();

    const handleAddProject = () => {
        if (!draftJobType || !draftDate) return;
        setProjects((prev) => [
            ...prev,
            {
                id: `pp-new-${Date.now()}`,
                jobType: draftJobType,
                completedAt: draftDate,
                notes: draftNotes,
            },
        ]);
        setDraftJobType('');
        setDraftDate('');
        setDraftNotes('');
        setAddingProject(false);
    };

    const handleRemoveProject = (id: string) => {
        setProjects((prev) => prev.filter((p) => p.id !== id));
    };

    const handleSave = () => {
        // In a real app: persist client to store/backend
        navigate('/clients');
    };

    return (
        <div className="min-h-screen bg-background pb-28 px-5 pt-14">
            <div className="max-w-[600px] mx-auto">
                {/* Header */}
                <button
                    onClick={() => navigate(-1)}
                    className="mb-6 text-system-blue flex items-center gap-0.5 -ml-1 active:opacity-70"
                >
                    <ChevronLeft className="w-5 h-5" />
                    <span className="text-[17px]">Back</span>
                </button>

                <motion.h1
                    initial={{ opacity: 0, y: 8 }}
                    animate={{ opacity: 1, y: 0 }}
                    className="text-[34px] font-bold mb-1 text-foreground tracking-tight"
                >
                    {prefillName ? 'Convert to Client' : 'New Client'}
                </motion.h1>
                {prefillName && (
                    <p className="text-muted-foreground text-[15px] mb-6">
                        from lead: {prefillName}
                    </p>
                )}
                {!prefillName && (
                    <p className="text-muted-foreground text-[15px] mb-6">
                        Add an existing client manually
                    </p>
                )}

                <div className="space-y-4">
                    {/* Name */}
                    <div>
                        <label className="block text-[11px] text-muted-foreground mb-1 uppercase tracking-wider">
                            Name *
                        </label>
                        <input
                            type="text"
                            value={name}
                            onChange={(e) => setName(e.target.value)}
                            placeholder="Client name"
                            className="w-full text-[17px] p-4 glass-elevated rounded-2xl focus:outline-none focus:ring-1 focus:ring-system-blue/50 text-foreground placeholder:text-muted-foreground"
                            autoFocus={!prefillName}
                        />
                    </div>

                    {/* Phone */}
                    <div>
                        <label className="block text-[11px] text-muted-foreground mb-1 uppercase tracking-wider">
                            Phone *
                        </label>
                        <input
                            type="tel"
                            value={phone}
                            onChange={(e) => setPhone(e.target.value)}
                            placeholder="Phone number"
                            className="w-full text-[17px] p-4 glass-elevated rounded-2xl focus:outline-none focus:ring-1 focus:ring-system-blue/50 text-foreground placeholder:text-muted-foreground"
                        />
                    </div>

                    {/* Email */}
                    <div>
                        <label className="block text-[11px] text-muted-foreground mb-1 uppercase tracking-wider">
                            Email
                        </label>
                        <input
                            type="email"
                            value={email}
                            onChange={(e) => setEmail(e.target.value)}
                            placeholder="Email (optional)"
                            className="w-full text-[17px] p-4 glass-elevated rounded-2xl focus:outline-none focus:ring-1 focus:ring-system-blue/50 text-foreground placeholder:text-muted-foreground"
                        />
                    </div>

                    {/* Address */}
                    <div>
                        <label className="block text-[11px] text-muted-foreground mb-1 uppercase tracking-wider">
                            Address
                        </label>
                        <input
                            type="text"
                            value={address}
                            onChange={(e) => setAddress(e.target.value)}
                            placeholder="Address (optional)"
                            className="w-full text-[17px] p-4 glass-elevated rounded-2xl focus:outline-none focus:ring-1 focus:ring-system-blue/50 text-foreground placeholder:text-muted-foreground"
                        />
                    </div>

                    {/* Notes */}
                    <div>
                        <label className="block text-[11px] text-muted-foreground mb-1 uppercase tracking-wider">
                            Notes
                        </label>
                        <textarea
                            value={notes}
                            onChange={(e) => setNotes(e.target.value)}
                            placeholder="Any notes about this client…"
                            rows={3}
                            className="w-full text-[17px] p-4 glass-elevated rounded-2xl resize-none focus:outline-none focus:ring-1 focus:ring-system-blue/50 text-foreground placeholder:text-muted-foreground"
                        />
                    </div>

                    {/* Previous Projects */}
                    <div>
                        <label className="block text-[11px] text-muted-foreground mb-2 uppercase tracking-wider">
                            Previous Projects
                        </label>
                        <div className="space-y-2 mb-3">
                            <AnimatePresence>
                                {projects.map((p) => (
                                    <motion.div
                                        key={p.id}
                                        initial={{ opacity: 0, height: 0 }}
                                        animate={{ opacity: 1, height: 'auto' }}
                                        exit={{ opacity: 0, height: 0 }}
                                        className="glass-elevated rounded-2xl p-4 flex items-start gap-3"
                                    >
                                        <CheckCircle2 className="w-4 h-4 text-system-green mt-0.5 flex-shrink-0" />
                                        <div className="flex-1 min-w-0">
                                            <p className="text-[15px] font-medium text-foreground">{p.jobType}</p>
                                            <p className="text-[13px] text-muted-foreground">{p.completedAt}</p>
                                            {p.notes && (
                                                <p className="text-[13px] text-muted-foreground/70 mt-0.5 line-clamp-1">
                                                    {p.notes}
                                                </p>
                                            )}
                                        </div>
                                        <button
                                            onClick={() => handleRemoveProject(p.id)}
                                            className="text-muted-foreground active:opacity-60 flex-shrink-0"
                                        >
                                            <X className="w-4 h-4" />
                                        </button>
                                    </motion.div>
                                ))}
                            </AnimatePresence>
                        </div>

                        {/* Add project form */}
                        <AnimatePresence>
                            {addingProject && (
                                <motion.div
                                    initial={{ opacity: 0, height: 0 }}
                                    animate={{ opacity: 1, height: 'auto' }}
                                    exit={{ opacity: 0, height: 0 }}
                                    className="glass-elevated rounded-2xl p-4 space-y-3 mb-3 overflow-hidden"
                                >
                                    <p className="text-[13px] text-muted-foreground uppercase tracking-wider font-medium">
                                        Add Project
                                    </p>
                                    {/* Job type picker */}
                                    <div className="flex flex-wrap gap-2">
                                        {jobTypes.map((type) => (
                                            <button
                                                key={type}
                                                onClick={() => setDraftJobType(type)}
                                                className={`px-3 py-1.5 rounded-full text-[13px] font-medium transition-all ${draftJobType === type
                                                        ? 'bg-system-blue text-white'
                                                        : 'glass-prominent text-foreground'
                                                    }`}
                                            >
                                                {type}
                                            </button>
                                        ))}
                                    </div>
                                    <div>
                                        <label className="block text-[11px] text-muted-foreground mb-1 uppercase tracking-wider">
                                            Completion Date
                                        </label>
                                        <input
                                            type="date"
                                            value={draftDate}
                                            onChange={(e) => setDraftDate(e.target.value)}
                                            className="w-full bg-transparent text-[15px] text-foreground focus:outline-none cursor-pointer"
                                        />
                                    </div>
                                    <input
                                        type="text"
                                        value={draftNotes}
                                        onChange={(e) => setDraftNotes(e.target.value)}
                                        placeholder="Project notes (optional)"
                                        className="w-full bg-transparent text-[15px] text-foreground focus:outline-none placeholder:text-muted-foreground border-b border-white/10 pb-1"
                                    />
                                    <div className="flex gap-2 pt-1">
                                        <button
                                            onClick={handleAddProject}
                                            disabled={!draftJobType || !draftDate}
                                            className="flex-1 bg-system-blue text-white py-2.5 rounded-xl text-[14px] font-semibold disabled:opacity-40"
                                        >
                                            Add
                                        </button>
                                        <button
                                            onClick={() => setAddingProject(false)}
                                            className="flex-1 glass-prominent text-foreground py-2.5 rounded-xl text-[14px] font-medium"
                                        >
                                            Cancel
                                        </button>
                                    </div>
                                </motion.div>
                            )}
                        </AnimatePresence>

                        {!addingProject && (
                            <button
                                onClick={() => setAddingProject(true)}
                                className="w-full glass-elevated rounded-2xl p-3.5 flex items-center justify-center gap-2 text-system-blue active:opacity-70"
                            >
                                <Plus className="w-4 h-4" />
                                <span className="text-[15px] font-medium">Add Previous Project</span>
                            </button>
                        )}
                    </div>

                    {/* Save */}
                    <motion.button
                        whileTap={{ scale: 0.97 }}
                        onClick={handleSave}
                        disabled={!canSave}
                        className="w-full bg-system-blue text-white py-4 rounded-2xl text-[17px] font-semibold mt-2 disabled:opacity-40"
                    >
                        Save Client
                    </motion.button>
                </div>
            </div>
        </div>
    );
}
