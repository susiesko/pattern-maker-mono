import { useParams } from 'react-router-dom';
import BeadForm from '../components/forms/add-edit-bead/BeadForm.tsx';
import useBeadQuery from '../hooks/queries/useBeadQuery';

const EditBeadPage = () => {
  const { id } = useParams<{ id: string }>();
  const beadId = id ? parseInt(id) : null;
  const { data: bead, isLoading, error } = useBeadQuery(beadId);

  if (isLoading) {
    return <div>Loading bead data...</div>;
  }

  if (error || !bead) {
    return <div>Error loading bead. Please try again later.</div>;
  }

  return <BeadForm bead={bead} isEdit={true} />;
};

export default EditBeadPage;
