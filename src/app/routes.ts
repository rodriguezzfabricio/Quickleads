import { createBrowserRouter } from 'react-router';
import { Layout } from './components/Layout';
import { HomeScreen } from './screens/HomeScreen';
import { LeadCaptureScreen } from './screens/LeadCaptureScreen';
import { LeadsScreen } from './screens/LeadsScreen';
import { LeadDetailScreen } from './screens/LeadDetailScreen';
import { JobsScreen } from './screens/JobsScreen';
import { JobDetailScreen } from './screens/JobDetailScreen';
import { FollowUpSettingsScreen } from './screens/FollowUpSettingsScreen';
import { DataImportScreen } from './screens/DataImportScreen';
import { SettingsScreen } from './screens/SettingsScreen';
import { ClientsScreen } from './screens/ClientsScreen';
import { ClientDetailScreen } from './screens/ClientDetailScreen';
import { AddClientScreen } from './screens/AddClientScreen';

export const router = createBrowserRouter([
  {
    path: '/',
    Component: Layout,
    children: [
      { index: true, Component: HomeScreen },
      { path: 'leads', Component: LeadsScreen },
      { path: 'leads/:id', Component: LeadDetailScreen },
      { path: 'jobs', Component: JobsScreen },
      { path: 'jobs/:id', Component: JobDetailScreen },
      { path: 'clients', Component: ClientsScreen },
      { path: 'clients/new', Component: AddClientScreen },
      { path: 'clients/:id', Component: ClientDetailScreen },
    ],
  },
  {
    path: '/lead-capture',
    Component: LeadCaptureScreen,
  },
  {
    path: '/follow-up-settings',
    Component: FollowUpSettingsScreen,
  },
  {
    path: '/onboarding',
    Component: DataImportScreen,
  },
  {
    path: '/settings',
    Component: SettingsScreen,
  },
]);
