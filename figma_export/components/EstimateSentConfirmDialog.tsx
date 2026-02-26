import {
  AlertDialog,
  AlertDialogAction,
  AlertDialogCancel,
  AlertDialogContent,
  AlertDialogDescription,
  AlertDialogFooter,
  AlertDialogHeader,
  AlertDialogTitle,
} from './ui/alert-dialog';

interface EstimateSentConfirmDialogProps {
  clientName: string;
  open: boolean;
  onOpenChange: (open: boolean) => void;
  onConfirm: () => void;
}

export function EstimateSentConfirmDialog({
  clientName,
  open,
  onOpenChange,
  onConfirm,
}: EstimateSentConfirmDialogProps) {
  return (
    <AlertDialog open={open} onOpenChange={onOpenChange}>
      <AlertDialogContent className="glass-elevated border-white/10 rounded-2xl p-5">
        <AlertDialogHeader>
          <AlertDialogTitle className="text-[20px] text-foreground">
            Start automatic follow-ups?
          </AlertDialogTitle>
          <AlertDialogDescription className="text-[15px] text-muted-foreground">
            Start automatic follow-ups for {clientName}?
          </AlertDialogDescription>
        </AlertDialogHeader>
        <AlertDialogFooter className="gap-2 sm:justify-start">
          {/* "Yes" is the primary path for activating paid-value automation. */}
          <AlertDialogAction
            onClick={onConfirm}
            className="bg-system-yellow text-black hover:bg-system-yellow/90 rounded-xl h-12 px-5 text-[15px] font-semibold"
          >
            Yes
          </AlertDialogAction>
          <AlertDialogCancel className="rounded-xl h-12 px-5 text-[15px] border-white/10 bg-transparent text-foreground hover:bg-white/[0.05]">
            No
          </AlertDialogCancel>
        </AlertDialogFooter>
      </AlertDialogContent>
    </AlertDialog>
  );
}
