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

interface ActionConfirmDialogProps {
  open: boolean;
  onOpenChange: (open: boolean) => void;
  title: string;
  description: string;
  confirmLabel: string;
  cancelLabel?: string;
  destructive?: boolean;
  onConfirm: () => void;
}

export function ActionConfirmDialog({
  open,
  onOpenChange,
  title,
  description,
  confirmLabel,
  cancelLabel = 'Cancel',
  destructive = false,
  onConfirm,
}: ActionConfirmDialogProps) {
  return (
    <AlertDialog open={open} onOpenChange={onOpenChange}>
      <AlertDialogContent className="glass-elevated border-white/10 rounded-2xl p-5">
        <AlertDialogHeader>
          <AlertDialogTitle className="text-[20px] text-foreground">{title}</AlertDialogTitle>
          <AlertDialogDescription className="text-[15px] text-muted-foreground">
            {description}
          </AlertDialogDescription>
        </AlertDialogHeader>
        <AlertDialogFooter className="gap-2 sm:justify-start">
          <AlertDialogAction
            onClick={onConfirm}
            className={
              destructive
                ? 'bg-system-red text-white hover:bg-system-red/90 rounded-xl h-12 px-5 text-[15px] font-semibold'
                : 'bg-system-blue text-white hover:bg-system-blue/90 rounded-xl h-12 px-5 text-[15px] font-semibold'
            }
          >
            {confirmLabel}
          </AlertDialogAction>
          <AlertDialogCancel className="rounded-xl h-12 px-5 text-[15px] border-white/10 bg-transparent text-foreground hover:bg-white/[0.05]">
            {cancelLabel}
          </AlertDialogCancel>
        </AlertDialogFooter>
      </AlertDialogContent>
    </AlertDialog>
  );
}
