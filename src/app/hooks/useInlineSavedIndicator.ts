import { useCallback, useEffect, useRef, useState } from 'react';

export function useInlineSavedIndicator(durationMs = 1500) {
  const [savedField, setSavedField] = useState<string | null>(null);
  const timeoutRef = useRef<number | undefined>(undefined);

  const showSaved = useCallback(
    (field: string) => {
      setSavedField(field);
      if (timeoutRef.current) window.clearTimeout(timeoutRef.current);
      timeoutRef.current = window.setTimeout(() => {
        setSavedField(null);
      }, durationMs);
    },
    [durationMs],
  );

  useEffect(
    () => () => {
      if (timeoutRef.current) window.clearTimeout(timeoutRef.current);
    },
    [],
  );

  return {
    showSaved,
    isFieldSaved: (field: string) => savedField === field,
  };
}
