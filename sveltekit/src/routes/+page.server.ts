import { env } from '$env/dynamic/private';
import type { PageServerLoad } from './$types';

export const load: PageServerLoad = async (event) => {
	const response = await fetch(`${env.API_URL}/api/test`);
	const data = await response.json();

	return {
		data
	};
};
