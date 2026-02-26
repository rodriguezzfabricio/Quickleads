import { useState } from 'react';
import { useNavigate, useParams } from 'react-router';
import {
    ChevronLeft,
    Phone,
    MessageSquare,
    Plus,
    Briefcase,
    CheckCircle2,
    XCircle,
    ChevronDown,
    ChevronUp,
    Mail,
    MapPin,
} from 'lucide-react';
import { mockClients } from '../data/mockData';
import { PreviousProject } from '../types';
import { motion, AnimatePresence } from 'motion/react';
import { format } from 'date-fns';
import { useInlineSavedIndicator } from '../hooks/useInlineSavedIndicator';
import { InlineSavedIndicator } from '../components/InlineSavedIndicator';

function ProjectRow({ project }: { project: PreviousProject }) {
    const [isExpanded, setIsExpanded] = useState(false);
    const isCompleted = project.status === 'completed';

    return (
        <div className="py-3">
            <button
                onClick={() => setIsExpanded(!isExpanded)}
                className="w-full flex items-start gap-3 text-left active:opacity-70 transition-opacity"
            >
                <div className="mt-0.5 flex-shrink-0">
                    {isCompleted ? (
                        <CheckCircle2 className="w-4 h-4 text-system-green" />
                    ) : (
                        <XCircle className="w-4 h-4 text-muted-foreground" />
                    )}
                </div>
                <div className="flex-1 min-w-0">
                    <div className="flex items-center justify-between gap-2">
                        <span className="text-[15px] font-medium text-foreground">{project.jobType}</span>
                        <div className="flex items-center gap-2">
                            <span
                                className={`text-[11px] font-semibold px-2 py-0.5 rounded-full flex-shrink-0 ${isCompleted
                                    ? 'bg-system-green/15 text-system-green'
                                    : 'bg-muted-foreground/15 text-muted-foreground'
                                    }`}
                            >
                                {isCompleted ? 'Completed' : 'Cancelled'}
                            </span>
                            {isExpanded ? (
                                <ChevronUp className="w-4 h-4 text-muted-foreground" />
                            ) : (
                                <ChevronDown className="w-4 h-4 text-muted-foreground" />
                            )}
                        </div>
                    </div>
                    {isExpanded ? (
                        <div className="mt-2 text-[13px] text-muted-foreground space-y-1">
                            {project.startedAt && (
                                <p>Started: {format(project.startedAt, 'MMM d, yyyy')}</p>
                            )}
                            <p>Completed: {format(project.completedAt, 'MMM d, yyyy')}</p>
                            {project.notes && (
                                <p className="mt-2 text-foreground/80 leading-snug">{project.notes}</p>
                            )}
                        </div>
                    ) : (
                        <>
                            <p className="text-[13px] text-muted-foreground mt-0.5">
                                {format(project.completedAt, 'MMM d, yyyy')}
                            </p>
                            {project.notes && (
                                <p className="text-[13px] text-muted-foreground/70 mt-1 leading-snug line-clamp-2">
                                    {project.notes}
                                </p>
                            )}
                        </>
                    )}
                </div>
            </button>
            <AnimatePresence>
                {isExpanded && project.photos && project.photos.length > 0 && (
                    <motion.div
                        initial={{ opacity: 0, height: 0 }}
                        animate={{ opacity: 1, height: 'auto' }}
                        exit={{ opacity: 0, height: 0 }}
                        className="mt-3 pl-7 overflow-hidden"
                    >
                        <div className="flex gap-2 overflow-x-auto pb-2 snap-x hide-scrollbar">
                            {project.photos.map((photo, i) => (
                                <img
                                    key={i}
                                    src={photo}
                                    alt={`Project preview ${i + 1}`}
                                    className="h-24 w-24 object-cover rounded-xl flex-shrink-0 snap-center border border-white/10"
                                />
                            ))}
                        </div>
                    </motion.div>
                )}
            </AnimatePresence>
        </div>
    );
}

export function ClientDetailScreen() {
    const navigate = useNavigate();
    const { id } = useParams();
    const client = mockClients.find((c) => c.id === id);

    const [isEditing, setIsEditing] = useState(false);
    const [name, setName] = useState(client?.name || '');
    const [phone, setPhone] = useState(client?.phone || '');
    const [showDetails, setShowDetails] = useState(false);
    const [notes, setNotes] = useState(client?.notes || '');
    const [email, setEmail] = useState(client?.email || '');
    const [address, setAddress] = useState(client?.address || '');
    const { showSaved, isFieldSaved } = useInlineSavedIndicator();

    if (!client)
        return (
            <div className="min-h-screen bg-background flex items-center justify-center">
                <p className="text-muted-foreground">Client not found</p>
            </div>
        );

    const handleCallNow = () => { window.location.href = `tel:${phone}`; };
    const handleSendText = () => { window.location.href = `sms:${phone}`; };
    const handleNewProject = () => {
        navigate(`/projects/new?name=${encodeURIComponent(name)}&phone=${encodeURIComponent(phone)}`);
    };

    return (
        <div className="min-h-screen bg-background pb-28">
            <div className="max-w-[600px] mx-auto">

                {/* Sticky Header */}
                <div className="sticky top-0 bg-background/70 backdrop-blur-2xl px-5 pt-14 pb-3 z-10">
                    <div className="flex items-start justify-between">
                        <button
                            onClick={() => navigate('/clients')}
                            className="mb-3 text-system-blue active:opacity-70 flex items-center gap-0.5 -ml-1"
                        >
                            <ChevronLeft className="w-5 h-5" />
                            <span className="text-[17px]">Clients</span>
                        </button>
                        <button
                            onClick={() => setIsEditing((v) => !v)}
                            className="text-system-blue text-[17px] font-medium active:opacity-70 mt-0.5"
                        >
                            {isEditing ? 'Done' : 'Edit'}
                        </button>
                    </div>

                    {/* Avatar + Name */}
                    <div className="flex items-center gap-3">
                        <div className="w-14 h-14 rounded-full bg-system-blue/20 flex items-center justify-center flex-shrink-0">
                            <span className="text-system-blue font-bold text-[22px]">
                                {name.charAt(0)}
                            </span>
                        </div>
                        <div className="flex-1 min-w-0">
                            {isEditing ? (
                                <input
                                    value={name}
                                    onChange={(e) => {
                                        setName(e.target.value);
                                        showSaved('name');
                                    }}
                                    className="text-[28px] font-bold text-foreground tracking-tight bg-transparent w-full focus:outline-none border-b border-system-blue/50 pb-0.5"
                                    autoFocus
                                />
                            ) : (
                                <motion.h1
                                    key="name-display"
                                    initial={{ opacity: 0, y: 8 }}
                                    animate={{ opacity: 1, y: 0 }}
                                    className="text-[28px] font-bold text-foreground tracking-tight leading-tight"
                                >
                                    {name}
                                </motion.h1>
                            )}
                            <p className="text-muted-foreground text-[14px]">
                                Client since {format(client.createdAt, 'MMM yyyy')}
                            </p>
                            <InlineSavedIndicator visible={isFieldSaved('name')} />
                        </div>
                    </div>
                </div>

                <div className="px-5 space-y-4 pt-3">

                    {/* Phone */}
                    <motion.div
                        initial={{ opacity: 0, y: 8 }}
                        animate={{ opacity: 1, y: 0 }}
                        transition={{ delay: 0.05 }}
                        className="glass-elevated rounded-2xl overflow-hidden"
                    >
                        {isEditing ? (
                            <div className="flex items-center gap-3 p-4">
                                <Phone className="w-5 h-5 text-system-blue flex-shrink-0" />
                                <input
                                    value={phone}
                                    onChange={(e) => {
                                        setPhone(e.target.value);
                                        showSaved('phone');
                                    }}
                                    type="tel"
                                    className="flex-1 bg-transparent text-[17px] text-foreground focus:outline-none placeholder:text-muted-foreground"
                                />
                                <InlineSavedIndicator visible={isFieldSaved('phone')} />
                            </div>
                        ) : (
                            <button
                                onClick={handleCallNow}
                                className="w-full flex items-center gap-3 p-4 active:bg-white/[0.02]"
                            >
                                <Phone className="w-5 h-5 text-system-blue" />
                                <span className="text-[17px] text-foreground">{phone}</span>
                            </button>
                        )}
                    </motion.div>

                    {/* Quick info pills (email / address) — read-only preview */}
                    {(client.email || client.address) && !showDetails && (
                        <motion.div
                            initial={{ opacity: 0, y: 8 }}
                            animate={{ opacity: 1, y: 0 }}
                            transition={{ delay: 0.08 }}
                            className="flex flex-col gap-2"
                        >
                            {client.email && (
                                <div className="glass-elevated rounded-2xl flex items-center gap-3 px-4 py-3">
                                    <Mail className="w-4 h-4 text-muted-foreground flex-shrink-0" />
                                    <span className="text-[15px] text-muted-foreground">{client.email}</span>
                                </div>
                            )}
                            {client.address && (
                                <div className="glass-elevated rounded-2xl flex items-center gap-3 px-4 py-3">
                                    <MapPin className="w-4 h-4 text-muted-foreground flex-shrink-0" />
                                    <span className="text-[15px] text-muted-foreground">{client.address}</span>
                                </div>
                            )}
                        </motion.div>
                    )}

                    {/* Previous Projects */}
                    <motion.div
                        initial={{ opacity: 0, y: 8 }}
                        animate={{ opacity: 1, y: 0 }}
                        transition={{ delay: 0.1 }}
                        className="glass-elevated rounded-2xl overflow-hidden"
                    >
                        <div className="px-4 pt-4 pb-1 flex items-center gap-2">
                            <Briefcase className="w-4 h-4 text-muted-foreground" />
                            <span className="text-[11px] text-muted-foreground uppercase tracking-wider font-medium">
                                Previous Projects
                            </span>
                            <span className="ml-auto text-[11px] font-semibold text-muted-foreground">
                                {client.previousProjects.length}
                            </span>
                        </div>
                        {client.previousProjects.length === 0 ? (
                            <div className="px-4 pb-6 pt-4 text-center">
                                <div className="w-12 h-12 rounded-full bg-white/[0.03] flex items-center justify-center mx-auto mb-3">
                                    <Briefcase className="w-6 h-6 text-muted-foreground/50" />
                                </div>
                                <h3 className="text-[15px] font-semibold text-foreground mb-1">No Project History</h3>
                                <p className="text-[13px] text-muted-foreground leading-relaxed max-w-[200px] mx-auto">
                                    When you complete jobs for this client, they'll show up here.
                                </p>
                            </div>
                        ) : (
                            <div className="px-4 pb-2 divide-y divide-white/[0.04]">
                                {client.previousProjects.map((p) => (
                                    <ProjectRow key={p.id} project={p} />
                                ))}
                            </div>
                        )}
                    </motion.div>

                    {/* New Project CTA */}
                    <motion.div
                        initial={{ opacity: 0, y: 8 }}
                        animate={{ opacity: 1, y: 0 }}
                        transition={{ delay: 0.15 }}
                    >
                        <motion.button
                            whileTap={{ scale: 0.97 }}
                            onClick={handleNewProject}
                            className="w-full py-4 rounded-2xl text-[17px] font-semibold flex items-center justify-center gap-2 text-white"
                            style={{ background: 'linear-gradient(135deg, #0A84FF 0%, #34C759 100%)' }}
                        >
                            <Plus className="w-5 h-5" />
                            New Project
                        </motion.button>
                    </motion.div>

                    {/* Details Accordion */}
                    <motion.div
                        initial={{ opacity: 0, y: 8 }}
                        animate={{ opacity: 1, y: 0 }}
                        transition={{ delay: 0.2 }}
                    >
                        <button
                            onClick={() => setShowDetails(!showDetails)}
                            className="w-full flex items-center justify-between p-4 glass-elevated rounded-2xl"
                        >
                            <span className="font-medium text-[17px] text-foreground">Details</span>
                            {showDetails ? (
                                <ChevronUp className="w-5 h-5 text-muted-foreground" />
                            ) : (
                                <ChevronDown className="w-5 h-5 text-muted-foreground" />
                            )}
                        </button>
                        <AnimatePresence>
                            {showDetails && (
                                <motion.div
                                    key="details"
                                    initial={{ opacity: 0, height: 0 }}
                                    animate={{ opacity: 1, height: 'auto' }}
                                    exit={{ opacity: 0, height: 0 }}
                                    className="mt-3 space-y-3 overflow-hidden"
                                >
                                    {[
                                        { label: 'Email', val: email, set: setEmail, type: 'email', ph: 'Email (optional)' },
                                        { label: 'Address', val: address, set: setAddress, type: 'text', ph: 'Address (optional)' },
                                    ].map((f) => (
                                        <div key={f.label}>
                                            <div className="mb-1 flex items-center justify-between">
                                                <label className="block text-[11px] text-muted-foreground uppercase tracking-wider">
                                                    {f.label}
                                                </label>
                                                <InlineSavedIndicator visible={isFieldSaved(f.label.toLowerCase())} />
                                            </div>
                                            <input
                                                type={f.type}
                                                value={f.val}
                                                onChange={(e) => {
                                                    f.set(e.target.value);
                                                    showSaved(f.label.toLowerCase());
                                                }}
                                                placeholder={f.ph}
                                                className="w-full p-4 glass-elevated rounded-2xl focus:outline-none focus:ring-1 focus:ring-system-blue/50 text-foreground placeholder:text-muted-foreground text-[17px]"
                                            />
                                        </div>
                                    ))}
                                    <div>
                                        <div className="mb-1 flex items-center justify-between">
                                            <label className="block text-[11px] text-muted-foreground uppercase tracking-wider">
                                                Notes
                                            </label>
                                            <InlineSavedIndicator visible={isFieldSaved('notes')} />
                                        </div>
                                        <textarea
                                            value={notes}
                                            onChange={(e) => {
                                                setNotes(e.target.value);
                                                showSaved('notes');
                                            }}
                                            placeholder="Add notes…"
                                            rows={3}
                                            className="w-full p-4 glass-elevated rounded-2xl resize-none focus:outline-none focus:ring-1 focus:ring-system-blue/50 text-foreground placeholder:text-muted-foreground text-[17px]"
                                        />
                                    </div>
                                </motion.div>
                            )}
                        </AnimatePresence>
                    </motion.div>

                    {/* Bottom Actions */}
                    <motion.div
                        initial={{ opacity: 0, y: 8 }}
                        animate={{ opacity: 1, y: 0 }}
                        transition={{ delay: 0.25 }}
                        className="space-y-3 pt-2"
                    >
                        <motion.button
                            whileTap={{ scale: 0.97 }}
                            onClick={handleCallNow}
                            className="w-full bg-system-blue text-white py-4 rounded-2xl text-[17px] font-semibold flex items-center justify-center gap-2"
                        >
                            <Phone className="w-5 h-5" />
                            Call Now
                        </motion.button>
                        <motion.button
                            whileTap={{ scale: 0.97 }}
                            onClick={handleSendText}
                            className="w-full glass-prominent text-foreground py-4 rounded-2xl text-[17px] font-semibold flex items-center justify-center gap-2"
                        >
                            <MessageSquare className="w-5 h-5" />
                            Send Text
                        </motion.button>
                    </motion.div>
                </div>
            </div>
        </div>
    );
}
