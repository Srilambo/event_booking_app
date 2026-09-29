import crypto from 'crypto';

export const generateBookingCode = (prefix = 'EVT') => {
  const bytes = crypto.randomBytes(4).toString('hex').toUpperCase();
  const timestamp = Date.now().toString(36).toUpperCase().slice(-4);
  return `${prefix}-${timestamp}-${bytes}`;
};
