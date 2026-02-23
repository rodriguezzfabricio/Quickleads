import { useState } from 'react';
import { useNavigate } from 'react-router';
import { Upload, CheckCircle } from 'lucide-react';
import { motion } from 'motion/react';

export function DataImportScreen() {
  const navigate = useNavigate();
  const [imported, setImported] = useState(false);
  const [importCount, setImportCount] = useState({ leads: 0, jobs: 0 });

  const handleFileUpload = () => {
    setTimeout(() => { setImportCount({ leads: 12, jobs: 5 }); setImported(true); }, 1000);
  };

  if (imported) {
    return (
      <div className="min-h-screen bg-background flex items-center justify-center px-5">
        <motion.div initial={{ scale: 0.9, opacity: 0 }} animate={{ scale: 1, opacity: 1 }} className="max-w-md text-center">
          <div className="w-20 h-20 bg-system-green/15 rounded-full flex items-center justify-center mx-auto mb-6">
            <CheckCircle className="w-12 h-12 text-system-green" />
          </div>
          <h1 className="text-[28px] font-bold mb-3 text-foreground tracking-tight">Import Successful!</h1>
          <p className="text-muted-foreground text-[15px] mb-8">{importCount.leads} leads and {importCount.jobs} jobs imported.</p>
          <motion.button whileTap={{ scale: 0.97 }} onClick={() => navigate('/')} className="w-full bg-system-blue text-white py-4 rounded-2xl text-[17px] font-semibold">
            Go to Dashboard
          </motion.button>
        </motion.div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-background flex items-center justify-center px-5">
      <div className="max-w-md w-full">
        <motion.div initial={{ opacity: 0, y: 12 }} animate={{ opacity: 1, y: 0 }} className="text-center mb-10">
          <h1 className="text-[28px] font-bold mb-3 text-foreground tracking-tight">Welcome to CrewCommand</h1>
          <p className="text-muted-foreground text-[15px]">Import your leads and jobs to get started.</p>
        </motion.div>

        <div className="space-y-4">
          <motion.button initial={{ opacity: 0, y: 8 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: 0.1 }} whileTap={{ scale: 0.97 }}
            onClick={handleFileUpload} className="w-full glass-elevated rounded-2xl p-5">
            <div className="flex items-center gap-4">
              <div className="w-12 h-12 bg-system-blue/15 rounded-2xl flex items-center justify-center flex-shrink-0">
                <Upload className="w-6 h-6 text-system-blue" />
              </div>
              <div className="text-left">
                <h3 className="font-semibold text-[17px] mb-0.5 text-foreground">Upload Spreadsheet</h3>
                <p className="text-[13px] text-muted-foreground">CSV or Excel</p>
              </div>
            </div>
          </motion.button>

          <motion.button initial={{ opacity: 0, y: 8 }} animate={{ opacity: 1, y: 0 }} transition={{ delay: 0.15 }} whileTap={{ scale: 0.97 }}
            onClick={() => navigate('/')} className="w-full bg-system-blue text-white py-4 rounded-2xl text-[17px] font-semibold">
            I'm Starting Fresh
          </motion.button>
        </div>
        <p className="text-center text-[13px] text-muted-foreground mt-6">Import later from Settings</p>
      </div>
    </div>
  );
}
