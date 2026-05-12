import { format, formatDistanceToNow, isValid, parseISO } from 'date-fns';
import { es } from 'date-fns/locale';

const toDate = (value: string | Date | null | undefined): Date | null => {
  if (!value) return null;
  const d = typeof value === 'string' ? parseISO(value) : value;
  return isValid(d) ? d : null;
};

export const formatDate = (value: string | Date | null | undefined, pattern = 'dd MMM yyyy'): string => {
  const d = toDate(value);
  return d ? format(d, pattern, { locale: es }) : '—';
};

export const formatDateTime = (value: string | Date | null | undefined): string => {
  const d = toDate(value);
  return d ? format(d, "dd MMM yyyy 'a las' HH:mm", { locale: es }) : '—';
};

export const fromNow = (value: string | Date | null | undefined): string => {
  const d = toDate(value);
  return d ? formatDistanceToNow(d, { addSuffix: true, locale: es }) : '—';
};
