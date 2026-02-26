import { useState, useMemo } from 'react';
import { useNavigate } from 'react-router';
import { Search, Plus, UserCircle2 } from 'lucide-react';
import { mockClients } from '../data/mockData';
import { motion } from 'motion/react';
import { format } from 'date-fns';

export function ClientsScreen() {
    const navigate = useNavigate();
    const [search, setSearch] = useState('');

    const filtered = useMemo(() => {
        const q = search.toLowerCase().trim();
        if (!q) return mockClients;
        return mockClients.filter(
            (c) =>
                c.name.toLowerCase().includes(q) ||
                c.phone.includes(q) ||
                c.email?.toLowerCase().includes(q)
        );
    }, [search]);

    return (
        <div className="pb-28">
            {/* Header */}
            <div className="sticky top-0 bg-background/70 backdrop-blur-2xl px-5 pt-14 pb-3 z-10">
                <div className="flex items-center justify-between mb-4">
                    <motion.h1
                        initial={{ opacity: 0, y: 8 }}
                        animate={{ opacity: 1, y: 0 }}
                        className="text-[34px] font-bold text-foreground tracking-tight"
                    >
                        Clients
                    </motion.h1>
                    <motion.button
                        initial={{ opacity: 0 }}
                        animate={{ opacity: 1 }}
                        whileTap={{ scale: 0.93 }}
                        onClick={() => navigate('/clients/new')}
                        className="w-9 h-9 bg-system-blue rounded-full flex items-center justify-center"
                    >
                        <Plus className="w-5 h-5 text-white" />
                    </motion.button>
                </div>

                {/* Search bar */}
                <div className="relative">
                    <Search className="absolute left-3.5 top-1/2 -translate-y-1/2 w-4 h-4 text-muted-foreground" />
                    <input
                        type="text"
                        value={search}
                        onChange={(e) => setSearch(e.target.value)}
                        placeholder="Search clients…"
                        className="w-full pl-10 pr-4 py-2.5 glass-elevated rounded-xl text-[15px] text-foreground placeholder:text-muted-foreground focus:outline-none focus:ring-1 focus:ring-system-blue/50"
                    />
                </div>
            </div>

            <div className="px-5 pt-3 space-y-2">
                {filtered.length === 0 ? (
                    <div className="text-center py-16">
                        <UserCircle2 className="w-14 h-14 text-muted-foreground/30 mx-auto mb-3" />
                        <p className="text-muted-foreground text-[17px]">No clients found</p>
                        <p className="text-muted-foreground/60 text-[13px] mt-1">
                            Tap + to add your first client
                        </p>
                    </div>
                ) : (
                    filtered.map((client, i) => (
                        <motion.button
                            key={client.id}
                            initial={{ opacity: 0, y: 8 }}
                            animate={{ opacity: 1, y: 0 }}
                            transition={{ delay: i * 0.04 }}
                            whileTap={{ scale: 0.97 }}
                            onClick={() => navigate(`/clients/${client.id}`)}
                            className="w-full glass-elevated rounded-2xl p-4 text-left"
                        >
                            <div className="flex items-start gap-3">
                                {/* Avatar initial */}
                                <div className="w-11 h-11 rounded-full bg-system-blue/20 flex items-center justify-center flex-shrink-0">
                                    <span className="text-system-blue font-bold text-[17px]">
                                        {client.name.charAt(0)}
                                    </span>
                                </div>
                                <div className="flex-1 min-w-0">
                                    <div className="flex items-center justify-between">
                                        <h3 className="font-semibold text-[17px] text-foreground">{client.name}</h3>
                                        <span className="text-[12px] text-muted-foreground flex-shrink-0 ml-2">
                                            {client.previousProjects.length} project
                                            {client.previousProjects.length !== 1 ? 's' : ''}
                                        </span>
                                    </div>
                                    <p className="text-muted-foreground text-[14px] mt-0.5">{client.phone}</p>
                                    {client.previousProjects.length > 0 && (
                                        <p className="text-muted-foreground/60 text-[12px] mt-1">
                                            Last:{' '}
                                            {client.previousProjects[0].jobType} ·{' '}
                                            {format(client.previousProjects[0].completedAt, 'MMM yyyy')}
                                        </p>
                                    )}
                                </div>
                            </div>
                        </motion.button>
                    ))
                )}
            </div>
        </div>
    );
}
