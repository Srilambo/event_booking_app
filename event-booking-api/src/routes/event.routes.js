import express from 'express';
import * as eventController from '../controllers/event.controller.js';
import { auth } from '../middleware/auth.js';
import { authorize } from '../middleware/role.js';
import { validate } from '../middleware/validate.js';
import { createEventSchema, updateEventSchema, getEventsQuerySchema } from '../validators/event.schema.js';
import { TokenService } from '../services/token.service.js';
import { User } from '../models/User.js';

const router = express.Router();

// Optional auth helper middleware for public GET routes
const optionalAuth = async (req, res, next) => {
  try {
    if (req.headers.authorization && req.headers.authorization.startsWith('Bearer ')) {
      const token = req.headers.authorization.split(' ')[1];
      const decoded = TokenService.verifyAccessToken(token);
      req.user = await User.findById(decoded.sub);
    }
  } catch (err) {
    // Ignore invalid token on optional route
  }
  next();
};

router.get('/', optionalAuth, validate(getEventsQuerySchema), eventController.getEvents);
router.get('/:id', optionalAuth, eventController.getEventById);

router.post('/', auth, authorize('organizer', 'admin'), validate(createEventSchema), eventController.createEvent);
router.put('/:id', auth, authorize('organizer', 'admin'), validate(updateEventSchema), eventController.updateEvent);
router.delete('/:id', auth, authorize('organizer', 'admin'), eventController.deleteEvent);

export default router;
